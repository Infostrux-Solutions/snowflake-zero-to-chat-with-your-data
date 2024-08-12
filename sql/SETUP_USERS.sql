-- noinspection SqlNoDataSourceInspectionForFile

-- ------------------ --
-- SETUP USER OBJECTS --
-- ------------------ --
SET participant_count = 1;
SET initial_password = 'LAB123';
-- jn4rjQ2zsja8y9XCh7QG9zCTLCMYe

USE WAREHOUSE LAB_ADMIN_WAREHOUSE;

DECLARE
    schema_prefix STRING DEFAULT 'CHAT_WITH_YOUR_DATA.WORKSPACE_';
    role_prefix STRING DEFAULT 'LAB_USER_ROLE_';
    user_prefix STRING DEFAULT 'LAB_USER_';
BEGIN
    FOR i IN 1 TO $participant_count DO

            USE ROLE SYSADMIN;

            LET user_schema_name := schema_prefix || i;
            CREATE SCHEMA IDENTIFIER(:user_schema_name);

            USE ROLE SECURITYADMIN;

            LET user_role_name := role_prefix || i;
            CREATE ROLE IDENTIFIER(:user_role_name);
            GRANT ROLE IDENTIFIER(:user_role_name) TO ROLE LAB_USER;

            GRANT USAGE ON WAREHOUSE LAB_USER_WAREHOUSE TO ROLE IDENTIFIER(:user_role_name);
            GRANT USAGE ON DATABASE CHAT_WITH_YOUR_DATA TO ROLE IDENTIFIER(:user_role_name);
            GRANT ALL PRIVILEGES ON SCHEMA IDENTIFIER(:user_schema_name) TO ROLE IDENTIFIER(:user_role_name);
            GRANT OWNERSHIP ON SCHEMA IDENTIFIER(:user_schema_name) TO ROLE IDENTIFIER(:user_role_name) REVOKE CURRENT GRANTS;

            LET user_name := user_prefix || i;
            CREATE USER IDENTIFIER(:user_name)
                PASSWORD = $initial_password
                DEFAULT_ROLE = :user_role_name
                MUST_CHANGE_PASSWORD = TRUE;
            ;

            GRANT ROLE IDENTIFIER(:user_role_name) TO USER IDENTIFIER(:user_name);
        END FOR;
    USE ROLE SYSADMIN;
    RETURN 'Successfully created participant objects';
END;
