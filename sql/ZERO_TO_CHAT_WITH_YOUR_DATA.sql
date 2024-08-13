-- Select user workspace
SET user_id = (SELECT ZEROIFNULL(REGEXP_SUBSTR(CURRENT_USER, '\\d+')));
SET user_namespace = (SELECT CONCAT('CHAT_WITH_YOUR_DATA.WORKSPACE_' || $user_id));
USE DATABASE CHAT_WITH_YOUR_DATA;
USE SCHEMA IDENTIFIER($user_namespace);

-- Create company_metadata table
CREATE OR REPLACE TABLE company_metadata
(
    cybersyn_company_id string,
    company_name string,
    permid_security_id string,
    primary_ticker string,
    security_name string,
    asset_class string,
    primary_exchange_code string,
    primary_exchange_name string,
    security_status string,
    global_tickers variant,
    exchange_code variant,
    permid_quote_id variant
);

CREATE OR REPLACE STAGE cybersyn_company_metadata
    URL = 's3://sfquickstarts/zero_to_snowflake/cybersyn-consumer-company-metadata-csv/'
;

LIST @cybersyn_company_metadata;

CREATE OR REPLACE FILE FORMAT csv
    TYPE = 'CSV'
        COMPRESSION = 'AUTO'  -- Automatically determines the compression of files
        FIELD_DELIMITER = ','  -- Specifies comma as the field delimiter
        RECORD_DELIMITER = '\n'  -- Specifies newline as the record delimiter
        SKIP_HEADER = 1  -- Skip the first line
        FIELD_OPTIONALLY_ENCLOSED_BY = '\042'  -- Fields are optionally enclosed by double quotes (ASCII code 34)
        TRIM_SPACE = FALSE  -- Spaces are not trimmed from fields
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE  -- Does not raise an error if the number of fields in the data file varies
        ESCAPE = 'NONE'  -- No escape character for special character escaping
        ESCAPE_UNENCLOSED_FIELD = '\134'  -- Backslash is the escape character for unenclosed fields
        DATE_FORMAT = 'AUTO'  -- Automatically detects the date format
        TIMESTAMP_FORMAT = 'AUTO'  -- Automatically detects the timestamp format
        NULL_IF = ('')  -- Treats empty strings as NULL values
    COMMENT = 'File format for ingesting data for zero to snowflake'
;

SHOW FILE FORMATS;

COPY INTO company_metadata
    FROM @cybersyn_company_metadata
    FILE_FORMAT = csv
    PATTERN = '.*csv.*'
    ON_ERROR = 'CONTINUE'
;

SELECT * FROM company_metadata LIMIT 10;

CREATE OR REPLACE TABLE sec_filings_index (v variant);

CREATE OR REPLACE TABLE sec_filings_attributes (v variant);

CREATE OR REPLACE STAGE cybersyn_sec_filings
    URL = 's3://sfquickstarts/zero_to_snowflake/cybersyn_cpg_sec_filings/'
;

LIST @cybersyn_sec_filings;

COPY INTO sec_filings_index
    FROM @cybersyn_sec_filings/cybersyn_sec_report_index.json.gz
    FILE_FORMAT = (type = json strip_outer_array = true)
;

SELECT * FROM sec_filings_index LIMIT 10;

COPY INTO sec_filings_attributes
    FROM @cybersyn_sec_filings/cybersyn_sec_report_attributes.json.gz
    FILE_FORMAT = (type = json strip_outer_array = true)
;

SELECT * FROM sec_filings_attributes LIMIT 10;

CREATE OR REPLACE VIEW sec_filings_index_view AS
SELECT
    v:CIK::string                   AS cik,
    v:COMPANY_NAME::string          AS company_name,
    v:EIN::int                      AS ein,
    v:ADSH::string                  AS adsh,
    v:TIMESTAMP_ACCEPTED::timestamp AS timestamp_accepted,
    v:FILED_DATE::date              AS filed_date,
    v:FORM_TYPE::string             AS form_type,
    v:FISCAL_PERIOD::string         AS fiscal_period,
    v:FISCAL_YEAR::string           AS fiscal_year
FROM sec_filings_index
;

CREATE OR REPLACE VIEW sec_filings_attributes_view AS
SELECT
    v:VARIABLE::string            AS variable,
    v:CIK::string                 AS cik,
    v:ADSH::string                AS adsh,
    v:MEASURE_DESCRIPTION::string AS measure_description,
    v:TAG::string                 AS tag,
    v:TAG_VERSION::string         AS tag_version,
    v:UNIT_OF_MEASURE::string     AS unit_of_measure,
    v:VALUE::string               AS value,
    v:REPORT::int                 AS report,
    v:STATEMENT::string           AS statement,
    v:PERIOD_START_DATE::date     AS period_start_date,
    v:PERIOD_END_DATE::date       AS period_end_date,
    v:COVERED_QTRS::int           AS covered_qtrs,
    TRY_PARSE_JSON(v:METADATA)    AS metadata
FROM sec_filings_attributes
;

SELECT * FROM sec_filings_index_view LIMIT 20;

SELECT * FROM sec_filings_attributes_view LIMIT 20;

-- Closing Price Statistics
SELECT
    meta.primary_ticker,
    meta.company_name,
    ts.date,
    ts.value AS post_market_close,
    (ts.value / LAG(ts.value, 1) OVER (PARTITION BY meta.primary_ticker ORDER BY ts.date))::DOUBLE AS daily_return,
    AVG(ts.value) OVER (PARTITION BY meta.primary_ticker ORDER BY ts.date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS five_day_moving_avg_price
FROM Financial__Economic_Essentials.cybersyn.stock_price_timeseries ts
         INNER JOIN company_metadata meta
                    ON ts.ticker = meta.primary_ticker
WHERE ts.variable_name = 'Post-Market Close';

-- Trading Volume Statistics
SELECT
    meta.primary_ticker,
    meta.company_name,
    ts.date,
    ts.value AS nasdaq_volume,
    (ts.value / LAG(ts.value, 1) OVER (PARTITION BY meta.primary_ticker ORDER BY ts.date))::DOUBLE AS volume_change
FROM Financial__Economic_Essentials.cybersyn.stock_price_timeseries ts
         INNER JOIN company_metadata meta
                    ON ts.ticker = meta.primary_ticker
WHERE ts.variable_name = 'Nasdaq Volume';

-- Clone a Table
CREATE TABLE company_metadata_dev CLONE company_metadata;

-- Joining Tables
WITH data_prep AS (
    SELECT
        idx.cik,
        idx.company_name,
        idx.adsh,
        idx.form_type,
        att.measure_description,
        CAST(att.value AS DOUBLE) AS value,
        att.period_start_date,
        att.period_end_date,
        att.covered_qtrs,
        TRIM(att.metadata:"ProductOrService"::STRING) AS product
    FROM sec_filings_attributes_view att
             JOIN sec_filings_index_view idx
                  ON idx.cik = att.cik AND idx.adsh = att.adsh
    WHERE idx.cik = '0001637459'
      AND idx.form_type IN ('10-K', '10-Q')
      AND LOWER(att.measure_description) = 'net sales'
      AND (att.metadata IS NULL OR OBJECT_KEYS(att.metadata) = ARRAY_CONSTRUCT('ProductOrService'))
      AND att.covered_qtrs IN (1, 4)
      AND value > 0
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY idx.cik, idx.company_name, att.measure_description, att.period_start_date, att.period_end_date, att.covered_qtrs, product
        ORDER BY idx.filed_date DESC
        ) = 1
)

SELECT
    company_name,
    measure_description,
    product,
    period_end_date,
    CASE
        WHEN covered_qtrs = 1 THEN value
        WHEN covered_qtrs = 4 THEN value - SUM(value) OVER (
            PARTITION BY cik, measure_description, product, YEAR(period_end_date)
            ORDER BY period_end_date
            ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
            )
        END AS quarterly_value
FROM data_prep
ORDER BY product, period_end_date;

-- Using Time Travel
-- Drop and Undrop a Table
DROP TABLE sec_filings_index;

-- The following query should result in an error because the underlying table has been dropped
SELECT * FROM sec_filings_index LIMIT 10;

-- Restore the table
UNDROP TABLE sec_filings_index;

SELECT * FROM sec_filings_index LIMIT 10;

-- Roll back changes to a table
-- Let's simulate an accidental column overwrite
UPDATE company_metadata SET company_name = 'oops';
SELECT company_name FROM company_metadata LIMIT 10;

-- Set the session variable with the query_id of the last UPDATE query
SET query_id = (
    SELECT query_id
    FROM TABLE(information_schema.query_history_by_session(result_limit=>5))
    WHERE query_text LIKE 'UPDATE%'
    ORDER BY start_time DESC
    LIMIT 1
);

-- Use the session variable with the identifier syntax (e.g., $query_id)
CREATE OR REPLACE TABLE company_metadata AS
SELECT *
FROM company_metadata
         BEFORE (STATEMENT => $query_id);

-- Verify the company names have been restored
SELECT company_name FROM company_metadata LIMIT 10;