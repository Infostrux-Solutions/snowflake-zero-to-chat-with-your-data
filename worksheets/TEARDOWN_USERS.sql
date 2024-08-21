-- noinspection SqlNoDataSourceInspectionForFile

-- --------------------- --
-- TEARDOWN USER OBJECTS --
-- --------------------- --
SET participant_count = 2;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAB_ADMIN_WAREHOUSE;

-- DROP users and their roles
DECLARE
    schema_prefix STRING DEFAULT 'CHAT_WITH_YOUR_DATA.WORKSPACE_';
    role_prefix STRING DEFAULT 'LAB_USER_ROLE_';
    user_prefix STRING DEFAULT 'LAB_USER_';
    warehouse_prefix STRING DEFAULT 'LAB_USER_WAREHOUSE_';
BEGIN
    FOR i IN 1 TO $participant_count DO
            LET user_schema_name := schema_prefix || i;
            DROP SCHEMA IF EXISTS IDENTIFIER(:user_schema_name);
            LET user_role_name := role_prefix || i;
            DROP ROLE IF EXISTS IDENTIFIER(:user_role_name);
            LET user_name := user_prefix || i;
            DROP USER IF EXISTS IDENTIFIER(:user_name);
            LET user_warehouse_name := warehouse_prefix || i;
            DROP WAREHOUSE IF EXISTS IDENTIFIER(:user_warehouse_name);
        END FOR;
    RETURN 'Done';
END;
