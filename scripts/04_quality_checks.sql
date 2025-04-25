/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the clean tables and dim/fact tables. It includes
    checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.
===============================================================================  
*/

-- ====================================================================
-- Checking 'clean_crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM clean_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key 
FROM clean_crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM clean_crm_cust_info;

-- ====================================================================
-- Checking 'clean_crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM clean_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prd_nm 
FROM clean_crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM clean_crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM clean_crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM clean_crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'cleab_crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    sls_order_dt 
FROM clean_crm_sales_details
WHERE sls_order_dt IS NULL
    OR sls_order_dt > '2026-01-01' 
    OR sls_order_dt < '1900-01-01';

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM clean_crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM clean_crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;   

-- ====================================================================
-- Checking 'clean_erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates before Today
SELECT DISTINCT 
    bdate 
FROM clean_erp_cust_az12
WHERE bdate > CURDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM clean_erp_cust_az12;

-- ====================================================================
-- Checking 'clean_erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM clean_erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'clean_erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM clean_erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
    maintenance
FROM clean_erp_px_cat_g1v2;

-- ====================================================================
-- Checking 'dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in dim_customers
-- Expectation: No results 
SELECT 
    customer_id,
    COUNT(*) AS duplicate_count
FROM dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'dim_products'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM fact_sales f
LEFT JOIN dim_customers c ON c.customer_id = f.customer_id
LEFT JOIN dim_products p ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
    OR c.customer_id IS NULL
