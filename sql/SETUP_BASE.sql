-- noinspection SqlNoDataSourceInspectionForFile

-- ------------------------- --
-- SETUP BASE INFRASTRUCTURE --
-- ------------------------- --
USE ROLE ACCOUNTADMIN;

-- Admin user
CREATE OR REPLACE ROLE HOL_ADMIN;
GRANT ROLE HOL_ADMIN TO ROLE SYSADMIN;
-- Participant user
CREATE OR REPLACE ROLE HOL_USER;
GRANT ROLE HOL_USER TO ROLE HOL_ADMIN;

-- Databases
USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS HOL_ADMIN_DB;
GRANT ALL PRIVILEGES ON DATABASE HOL_ADMIN_DB TO ROLE HOL_ADMIN;
CREATE OR REPLACE DATABASE HOL_USER_DB;
GRANT ALL PRIVILEGES ON DATABASE HOL_USER_DB TO ROLE HOL_ADMIN;

-- Warehouses
CREATE OR REPLACE WAREHOUSE HOL_ADMIN_WAREHOUSE WITH
INITIALLY_SUSPENDED = TRUE
-- WAREHOUSE_SIZE = 'LARGE'
-- WAREHOUSE_TYPE = 'SNOWPARK-OPTIMIZED'
;
GRANT USAGE ON WAREHOUSE HOL_ADMIN_WAREHOUSE TO ROLE HOL_ADMIN;

CREATE OR REPLACE WAREHOUSE HOL_USER_WAREHOUSE WITH
INITIALLY_SUSPENDED = TRUE
-- WAREHOUSE_SIZE = 'LARGE'
-- WAREHOUSE_TYPE = 'SNOWPARK-OPTIMIZED'
-- MAX_CLUSTER_COUNT = 10
;
GRANT USAGE ON WAREHOUSE HOL_USER_WAREHOUSE TO ROLE HOL_ADMIN;
