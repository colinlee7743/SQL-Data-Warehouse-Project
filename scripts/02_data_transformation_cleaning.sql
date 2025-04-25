/*
=============================================================================================================
Data Transformation and Cleaning
=============================================================================================================
Script Purpose:
    This script creates cleaned versions of tables after applying necessary transformations and data 
    cleaning steps, including:
	- Trims leading/trailing whitespaces from text fields to ensure data consistency.
	- Normalizes values to a standardized format (e.g., converting 'gender' to 'Male`, 'Female', or 'N/A').
    - Replaces missing or NULL values with placeholders like 'N/A' or '0' as appropriate.
    - Ensures proper data type consistency (e.g.,'DATE' for dates).
    - Recalculate sales if original value is missing or incorrect.
    - Derive price if original value is invalid.
=============================================================================================================
*/

-- ====================================================================
-- 1. Create clean table for CRM customers
-- ====================================================================
CREATE TABLE clean_crm_cust_info AS
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'N/A'
    END AS cst_marital_status, 					-- Normalised marital status values to readable format
    CASE
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'N/A'
    END AS cst_gndr,  						-- Normalised gender values to readable format
    cst_create_date
FROM (
    SELECT
	*,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM crm_cust_info
    WHERE cst_id IS NOT NULL) AS ranked_customers
WHERE flag_last = 1;						-- Select the most recent record per customer

-- ====================================================================
-- 2. Create clean table for CRM products 
-- ====================================================================
CREATE TABLE clean_crm_prd_info AS
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, 	-- Extract category ID
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key, 		-- Extract product key
    prd_nm,
    IFNULL(prd_cost, 0) AS prd_cost, 				-- SET product cost as 0 if is null
    CASE
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,						-- Normalised prd_line values to readable format
    prd_start_dt,
    DATE_SUB(
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
	INTERVAL 1 DAY) AS prd_end_dt
FROM crm_prd_info;

-- ====================================================================
-- 3. Create clean table for CRM sales
-- ====================================================================
CREATE TABLE clean_crm_sales_details AS
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE
	WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE CAST(STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d') AS DATE) 	-- Convert the sls_order_dt to DATE format
    END AS sls_order_dt,
    CASE
	WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d') AS DATE) 	-- Convert the sls_ship_dt to DATE format
    END AS sls_ship_dt,
    CASE
	WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE CAST(STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d') AS DATE) 	-- Convert the sls_ship_dt to DATE format
    END AS sls_due_dt,
    CASE
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
    END AS sls_sales,								-- Recalculate sales if original value is missing or incorrect
    sls_quantity,
    CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price  							-- Derive price if original value is invalid
    END AS sls_price
FROM crm_sales_details;

-- ====================================================================
-- 4. Create clean table for ERP customer 
-- ====================================================================
CREATE TABLE clean_erp_cust_az12 AS
SELECT
    CASE
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4) 	-- Remove 'NAS' prefix if present
	ELSE cid
    END AS cid, 
    CASE
	WHEN bdate > CURDATE() THEN NULL
	ELSE bdate
    END AS bdate, 					-- Set future birthdates to NULL
    CASE
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'N/A'
    END AS gen 						-- Normalize gender values and handle unknown cases
FROM erp_cust_az12; 

-- ====================================================================
-- 5. Create clean table for ERP location
-- ====================================================================
CREATE TABLE clean_erp_loc_a101 AS
SELECT
    REPLACE(cid, '-', '') AS cid, 
    CASE
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
	ELSE TRIM(cntry)
    END AS cntry 					-- Normalize and Handle missing or blank country codes
FROM erp_loc_a101;

-- ====================================================================
-- 6. Create table for ERP product
-- ====================================================================
CREATE TABLE clean_erp_px_cat_g1v2 AS
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM erp_px_cat_g1v2;					-- No cleaning or transformation needed

