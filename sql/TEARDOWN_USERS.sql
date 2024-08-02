-- --------------------- --
-- TEARDOWN USER OBJECTS --
-- --------------------- --
SET participant_count = 3;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE HOL_ADMIN_WAREHOUSE;

-- DROP users and their roles
DECLARE
    schema_prefix STRING DEFAULT 'HOL_USER_DB.WORKSPACE_';
    role_prefix STRING DEFAULT 'HOL_USER_ROLE_';
    user_prefix STRING DEFAULT 'HOL_USER_';
BEGIN
    FOR i IN 1 TO $participant_count DO
        LET user_schema_name := schema_prefix || i;
        DROP SCHEMA IDENTIFIER(:user_schema_name);
        LET user_role_name := role_prefix || i;
        DROP ROLE IF EXISTS IDENTIFIER(:user_role_name);
        LET user_name := user_prefix || i;
        DROP USER IF EXISTS IDENTIFIER(:user_name);
    END FOR;
END;
