/*
===============================================================================
Data Integration
===============================================================================
Script Purpose:
    This script merges data from cleaned CRM and ERP tables using 'LEFT JOIN' 
    operations to create unified dataset (dim_customers, dim_products, 
    fact_sales) for reporting and analysis.
===============================================================================
*/

-- ====================================================================
-- 1. Create dimension table for customers
-- ====================================================================
DROP TABLE IF EXISTS dim_customers;
CREATE TABLE dim_customers AS
SELECT
    ci.cst_id           AS customer_id,
    ci.cst_key          AS customer_key,
    ci.cst_firstname    AS first_name,
    ci.cst_lastname     AS last_name,
    la.cntry            AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END                 AS gender,
    ca.bdate            AS birthdate,
    ci.cst_create_date  AS create_date
FROM clean_crm_cust_info ci
LEFT JOIN clean_erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN clean_erp_loc_a101 la ON ci.cst_key = la.cid;

-- Set Primary Key for dim_customers
ALTER TABLE dim_customers ADD PRIMARY KEY (customer_id);

-- ====================================================================
-- 2. Create dimension table for products
-- ====================================================================
DROP TABLE IF EXISTS dim_products;
CREATE TABLE dim_products AS
SELECT
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_key,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM clean_crm_prd_info pn
LEFT JOIN clean_erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; 		-- Filter out historical data

-- Set Primary Key for dim_products
ALTER TABLE dim_products ADD PRIMARY KEY (product_key);

-- ====================================================================
-- 3. Create dimension table for sales
-- ====================================================================
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_id AS customer_id,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM clean_crm_sales_details sd
LEFT JOIN dim_products pr ON sd.sls_prd_key = pr.product_key
LEFT JOIN dim_customers cu ON sd.sls_cust_id = cu.customer_id;

-- Set Primary Key for fact_sales
-- Set Foreign Key for fact_sales based on product_key and customer_id
-- from dim_products and dim_customers

ALTER TABLE fact_sales 
ADD COLUMN sales_id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE fact_sales 
ADD CONSTRAINT fk_product_key
FOREIGN KEY (product_key) 
REFERENCES dim_products(product_key);

ALTER TABLE fact_sales 
ADD CONSTRAINT fk_customer_id
FOREIGN KEY (customer_id) 
REFERENCES dim_customers(customer_id);
