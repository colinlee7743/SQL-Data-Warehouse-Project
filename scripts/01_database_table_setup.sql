/*
===============================================================================
Database and Table Setup
===============================================================================
Script Purpose:
    This script creates a new database if it doesn't exist. It then drops any 
    existing tables (if they exist) and creates fresh tables. Finally, it 
    loads data from CSV files into the corresponding tables.
===============================================================================
*/

-- ====================================================================
-- 1. Create a new database
-- ====================================================================
CREATE DATABASE IF NOT EXISTS DataWarehouse;
USE DataWarehouse;

-- ====================================================================
-- 2. Create tables for CRM and ERP data
-- ====================================================================
-- 2.1 Create table for CRM customers
DROP TABLE IF EXISTS crm_cust_info;
CREATE TABLE crm_cust_info (
    cst_id              INT NULL,
    cst_key             VARCHAR(50) NULL,
    cst_firstname       VARCHAR(50) NULL,
    cst_lastname        VARCHAR(50) NULL,
    cst_marital_status  VARCHAR(50) NULL,
    cst_gndr            VARCHAR(50) NULL,
    cst_create_date     DATE NULL
);

-- 2.2 Create table for CRM products 
DROP TABLE IF EXISTS crm_prd_info;
CREATE TABLE crm_prd_info (
	prd_id       INT NULL,
    prd_key      VARCHAR(50) NULL,
    prd_nm       VARCHAR(50) NULL,
    prd_cost     INT NULL,
    prd_line     VARCHAR(50) NULL,
    prd_start_dt DATE NULL,
    prd_end_dt   DATE NULL
);

-- 2.3 Create table for CRM sales
DROP TABLE IF EXISTS crm_sales_details;
CREATE TABLE crm_sales_details (
    sls_ord_num  VARCHAR(50) NULL,
    sls_prd_key  VARCHAR(50) NULL,
    sls_cust_id  INT NULL,
    sls_order_dt INT NULL,
    sls_ship_dt  INT NULL,
    sls_due_dt   INT NULL,
    sls_sales    INT NULL,
    sls_quantity INT NULL,
    sls_price    INT NULL
);

-- 2.4 Create table for ERP location
DROP TABLE IF EXISTS erp_loc_a101;
CREATE TABLE erp_loc_a101 (
    cid    VARCHAR(50) NULL,
    cntry  NVARCHAR(50) NULL
);

-- 2.5 Create table for ERP customer 
DROP TABLE IF EXISTS erp_cust_az12;
CREATE TABLE erp_cust_az12 (
    cid    NVARCHAR(50) NULL,
    bdate  DATE NULL, 
    gen    NVARCHAR(50) NULL
);

-- 2.6 Create table for ERP product
DROP TABLE IF EXISTS erp_px_cat_g1v2;
CREATE TABLE erp_px_cat_g1v2 (
    id           NVARCHAR(50) NULL,
    cat          NVARCHAR(50) NULL,
    subcat       NVARCHAR(50) NULL,
    maintenance  NVARCHAR(50) NULL
);

-- ====================================================================
-- 3. Load data from CSV files into the tables
-- ====================================================================
-- 3.1 Load data into CRM customers
LOAD DATA LOCAL INFILE 'C:/Download/source_crm/cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
-- 3.2 Load data into CRM products
LOAD DATA LOCAL INFILE 'source_crm/prd_info.csv'
INTO TABLE crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3.3 Load data into CRM sales
LOAD DATA LOCAL INFILE 'C:/Download/source_crm/sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3.4 Load data into ERP location
LOAD DATA LOCAL INFILE 'C:/Download/source_erp/LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3.5 Load data into ERP customer
LOAD DATA LOCAL INFILE 'C:/Download/source_erp/CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3.6 Load data into ERP product
LOAD DATA LOCAL INFILE 'C:/Download/source_erp/PX_CAT_G1V2.csv'
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
