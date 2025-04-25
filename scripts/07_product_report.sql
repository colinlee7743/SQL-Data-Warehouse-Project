/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- =============================================================================
-- Create Report: report_products
-- =============================================================================
DROP VIEW IF EXISTS products_summary;

CREATE VIEW products_summary AS
WITH base_query AS 
(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
SELECT 
    f.order_number,
    f.customer_id,
    f.order_date,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM fact_sales f
LEFT JOIN dim_products p ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
),
prod_agg AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    MAX(order_date) as last_order_date,
    TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    CASE
	WHEN SUM(quantity) = 0 THEN 0.00
        ELSE ROUND(SUM(sales_amount) / SUM(quantity), 2) 
    END AS avg_selling_price
FROM base_query
GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    lifespan,
    TIMESTAMPDIFF(month, last_order_date, NOW()) AS recency,
    CASE
	WHEN total_sales > 50000 THEN 'High-Performer'
	wHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
    END AS product_grp,
    total_orders,
    total_customers,
    total_sales,
    total_quantity,
    avg_selling_price,
    -- Compuate average order revenue (AOR)
    CASE
	WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_revenue,
    
    -- Compuate average monthly revenue
    CASE
	WHEN lifespan = 0 THEN total_sales
        ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_mth_revenue
FROM prod_agg;
