-- noinspection SqlNoDataSourceInspectionForFile

-- ------------------ --
-- SETUP USER OBJECTS --
-- ------------------ --
SET participant_count = 2;
SET initial_password = 'LAB123';
-- jn4rjQ2zsja8y9XCh7QG9zCTLCMYe

USE WAREHOUSE LAB_ADMIN_WAREHOUSE;

DECLARE
    schema_prefix STRING DEFAULT 'CHAT_WITH_YOUR_DATA.WORKSPACE_';
    role_prefix STRING DEFAULT 'LAB_USER_ROLE_';
    user_prefix STRING DEFAULT 'LAB_USER_';
    warehouse_prefix STRING DEFAULT 'LAB_USER_WAREHOUSE_';
BEGIN
    FOR i IN 1 TO $participant_count DO

            USE ROLE SYSADMIN;

            LET user_schema_name := schema_prefix || i;
            CREATE OR REPLACE SCHEMA IDENTIFIER(:user_schema_name);
            LET user_warehouse_name := warehouse_prefix || i;
            CREATE OR REPLACE WAREHOUSE IDENTIFIER(:user_warehouse_name) WITH
                INITIALLY_SUSPENDED = TRUE
--                 WAREHOUSE_SIZE = 'LARGE'
--                 WAREHOUSE_TYPE = 'SNOWPARK-OPTIMIZED'
--                 AUTO_SUSPEND = 60
            ;

            USE ROLE SECURITYADMIN;

            LET user_role_name := role_prefix || i;
            CREATE ROLE IDENTIFIER(:user_role_name);
            GRANT ROLE IDENTIFIER(:user_role_name) TO ROLE LAB_USER;

            GRANT USAGE ON DATABASE CHAT_WITH_YOUR_DATA TO ROLE IDENTIFIER(:user_role_name);
            GRANT ALL PRIVILEGES ON SCHEMA IDENTIFIER(:user_schema_name) TO ROLE IDENTIFIER(:user_role_name);
            GRANT OWNERSHIP ON SCHEMA IDENTIFIER(:user_schema_name) TO ROLE IDENTIFIER(:user_role_name) REVOKE CURRENT GRANTS;
            GRANT USAGE ON WAREHOUSE IDENTIFIER(:user_warehouse_name) TO ROLE IDENTIFIER(:user_role_name);

            LET user_name := user_prefix || i;
            CREATE USER IDENTIFIER(:user_name)
                PASSWORD = $initial_password
                DEFAULT_ROLE = :user_role_name
                MUST_CHANGE_PASSWORD = TRUE;
            ;

            GRANT ROLE IDENTIFIER(:user_role_name) TO USER IDENTIFIER(:user_name);
        END FOR;
    USE ROLE SYSADMIN;
    RETURN 'Successfully created lab user objects';
END;
