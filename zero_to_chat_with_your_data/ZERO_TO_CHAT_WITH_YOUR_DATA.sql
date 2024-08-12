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
