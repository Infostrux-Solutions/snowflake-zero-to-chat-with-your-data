SET user_id = (SELECT ZEROIFNULL(REGEXP_SUBSTR(CURRENT_USER, '\\d+')));
SET user_namespace = (SELECT CONCAT('HOL_USER_DB.WORKSPACE_' || $user_id));

USE DATABASE HOL_USER_DB;
USE SCHEMA IDENTIFIER($user_namespace);

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
