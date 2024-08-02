-- ------------------ --
-- SETUP USER OBJECTS --
-- ------------------ --
SET participant_count = 3;
SET initial_password = 'HOL123';

USE WAREHOUSE HOL_ADMIN_WAREHOUSE;

DECLARE
    schema_prefix STRING DEFAULT 'HOL_USER_DB.WORKSPACE_';
    role_prefix STRING DEFAULT 'HOL_USER_ROLE_';
    user_prefix STRING DEFAULT 'HOL_USER_';
BEGIN
    FOR i IN 1 TO $participant_count DO

            USE ROLE SYSADMIN;

            LET user_schema_name := schema_prefix || i;
            CREATE SCHEMA IDENTIFIER(:user_schema_name);

            USE ROLE ACCOUNTADMIN;

            LET user_role_name := role_prefix || i;
            CREATE ROLE IDENTIFIER(:user_role_name);
            GRANT USAGE ON WAREHOUSE HOL_USER_WAREHOUSE TO ROLE IDENTIFIER(:user_role_name);
            GRANT USAGE ON DATABASE HOL_USER_DB TO ROLE IDENTIFIER(:user_role_name);
            GRANT ALL PRIVILEGES ON SCHEMA IDENTIFIER(:user_schema_name) TO ROLE IDENTIFIER(:user_role_name);
            GRANT OWNERSHIP ON SCHEMA IDENTIFIER(:user_schema_name) TO ROLE IDENTIFIER(:user_role_name) REVOKE CURRENT GRANTS;
            GRANT ROLE IDENTIFIER(:user_role_name) TO ROLE HOL_USER;

            LET user_name := user_prefix || i;
            CREATE USER IDENTIFIER(:user_name)
                PASSWORD = $initial_password
                DEFAULT_ROLE = :user_role_name
                MUST_CHANGE_PASSWORD = FALSE;
            ;

            GRANT ROLE IDENTIFIER(:user_role_name) TO USER IDENTIFIER(:user_name);
        END FOR;
    USE ROLE SYSADMIN;
    RETURN 'Successfully created participant objects';
END;
