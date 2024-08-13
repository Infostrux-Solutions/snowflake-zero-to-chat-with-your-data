-- Select user workspace
SET user_id = (SELECT ZEROIFNULL(REGEXP_SUBSTR(CURRENT_USER, '\\d+')));
SET user_namespace = (SELECT CONCAT('CHAT_WITH_YOUR_DATA.WORKSPACE_' || $user_id));
USE DATABASE CHAT_WITH_YOUR_DATA;
USE SCHEMA IDENTIFIER($user_namespace);

-- Create company_metadata table
CREATE OR REPLACE TABLE company_metadata (
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

-- Create external stage to load the data
CREATE OR REPLACE STAGE cybersyn_company_metadata
    URL = 's3://sfquickstarts/zero_to_snowflake/cybersyn-consumer-company-metadata-csv/'
;

LIST @cybersyn_company_metadata;

-- Creation of data format 
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

-- verify the file format has been created succesfully 
SHOW FILE FORMATS;

-- Load the data into COMPANY_METADATA table
COPY INTO company_metadata
    FROM @cybersyn_company_metadata
    FILE_FORMAT = csv
    PATTERN = '.*csv.*'
    ON_ERROR = 'CONTINUE'
;

SELECT * FROM company_metadata LIMIT 10;


-- LOAD SEMI-STRUCTURE DATA
-- create two tables, SEC_FILINGS_INDEX and SEC_FILINGS_ATTRIBUTES to use for loading JSON data

CREATE TABLE sec_filings_index (v variant);

CREATE TABLE sec_filings_attributes (v variant);

-- Create Another External Stage

CREATE OR REPLACE STAGE cybersyn_sec_filings
    URL = 's3://sfquickstarts/zero_to_snowflake/cybersyn_cpg_sec_filings/'
;

-- Take a look at the content of the chat_with_your_data_sec_filings

LIST @cybersyn_sec_filings;

-- Load and Verify the Semi-structured Data

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

-- Create a View and Query Semi-Structured Data

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
