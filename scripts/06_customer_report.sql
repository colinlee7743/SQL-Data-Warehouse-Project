/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	- total orders
	- total sales
	- total quantity purchased
	- total products
	- lifespan (in months)
    4. Calculates valuable KPIs:
	- recency (months since last order)
	- average order value
	- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: report_customers
-- =============================================================================
DROP VIEW IF EXISTS customer_summary;

CREATE VIEW customer_summary AS
WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.product_key,
    f.customer_id,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    CONCAT(c.first_name, ' ' , c.last_name) AS customer_name,
    TIMESTAMPDIFF(year, c.birthdate, NOW()) AS age -- To segment customer into diff age group_concat
FROM fact_sales f
LEFT JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE order_date IS NOT NULL
), 
cust_agg AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantities,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_name, age
)
SELECT 
    customer_key,
    customer_name,
    age,
    CASE 
	WHEN age < 20 THEN 'Under 20'
	WHEN age between 20 and 29 THEN '20-29'
	WHEN age between 30 and 39 THEN '30-39'
	WHEN age between 40 and 49 THEN '40-49'
	ELSE '50 and above'
    END AS age_grp,
    CASE 
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
    END AS cust_grp,
    total_orders     AS total_ord,
    total_sales      AS total_sls,
    total_quantities AS total_qty,
    total_products   AS total_prd,
    last_order_date  AS last_ord_dt,
    lifespan,
    TIMESTAMPDIFF(month, last_order_date, NOW()) AS recency,
    -- Compuate average order value (AVO)
    CASE
	WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_ord_val,
    
    -- Compuate average monthly spend
    CASE
	WHEN lifespan = 0 THEN total_sales
        ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_mth_spend
FROM cust_agg;
