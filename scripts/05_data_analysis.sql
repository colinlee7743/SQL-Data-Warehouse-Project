/*
=============================================================================================================
Data Analysis
=============================================================================================================
Purpose:
    - 1. Change Over Time Analysis: Analyse sales performance across different years or months
    - 2. Cumulative Analysis: Calculate total sales and running totals over time
    - 3. Performance Analysis (Year-over-Year): Compare product sales across different years to evaluate growth
    - 4. Part-to-Whole Analysis: Assess the contribution of each category to total sales
    - 5. Data Segmentation Analysis: Group products by cost ranges and customers by spending behavior
    
SQL Functions Used:
    - Date Functions: YEAR(), DATE_FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - Window Functions: SUM() OVER(), LAG() OVER(), AVG() OVER()
    - Conditional Logics: CASE WHEN ... END
    - Grouping Clause: GROUP BY
=============================================================================================================
*/

-- =============================================================================
-- Change Over Time Analysis
-- =============================================================================
-- Analyse sales performance over year
SELECT
    YEAR(order_date) as order_year,
    SUM(sales_amount) as total_sales,
    SUM(quantity) as quantity,
    COUNT(DISTINCT customer_id) as total_customers
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Analyse sales performance over month
SELECT
    DATE_FORMAT(order_date, '%Y%m') as order_date,
    SUM(sales_amount) as total_sales,
    SUM(quantity) as quantity,
    COUNT(DISTINCT customer_id) as total_customers
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y%m')
ORDER BY DATE_FORMAT(order_date, '%Y%m');

-- =============================================================================
-- Cumulative Analysis
-- =============================================================================
-- Calculate the total sales per month and the running total of sales over time 
SELECT 
    order_year,
    order_month,
    total_sales,
    sum(total_sales) OVER (PARTITION BY order_year ORDER BY order_month) AS running_sales
FROM (
    SELECT
	YEAR(order_date) as order_year,
        DATE_FORMAT(order_date, '%Y%m') as order_month,
	SUM(sales_amount) as total_sales
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), DATE_FORMAT(order_date, '%Y%m')
	ORDER BY YEAR(order_date), DATE_FORMAT(order_date, '%Y%m')
) AS temp;

-- =============================================================================
-- Performance Analysis (Year-over-Year)
-- =============================================================================
-- Analyze the yearly performance of products by comparing their sales 
-- to both the average sales performance of the product and the previous year's sales
WITH yearly_product_sales AS
(SELECT
    YEAR(f.order_date) as order_year,
    p.product_name,
    SUM(f.sales_amount) as current_sales
FROM fact_sales f
LEFT JOIN dim_products p ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    ROUND(avg(current_sales) OVER (PARTITION BY product_name), 0) as avg_sales,
    ROUND(current_sales - avg(current_sales) OVER (PARTITION BY product_name), 0) as diff_avg,
    CASE 
	WHEN current_sales - avg(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - avg(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
	END AS avg_change,
    
    -- Year-over-year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as diff_py,
     CASE 
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
	END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

-- =============================================================================
-- Part-to-Whole Analysis
-- =============================================================================
-- Which categories contribute the most to overall sales?
WITH category_sales AS (
SELECT
    p.category,
    SUM(f.sales_amount) as total_sales
FROM fact_sales f
LEFT JOIN dim_products p ON f.product_key = p.product_key
GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () as overall_sales,
    CONCAT(ROUND(total_sales / SUM(total_sales) OVER () * 100,2),'%') as sales_percentage
FROM category_sales
ORDER BY total_sales DESC;

-- =============================================================================
-- Data Segmentation Analysis
-- =============================================================================
-- Segment products into cost ranges and count how many products fall into each segment
WITH product_cost AS (
SELECT
    product_key,
    product_name,
    cost,
    CASE
	WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
	END AS cost_range
FROM dim_products
)
SELECT
    cost_range,
    COUNT(*) AS total_products
FROM product_cost
GROUP BY cost_range
ORDER BY total_products DESC;

-- Group customers into three segments based on their spending behavior:
--  1. VIP: Customers with at least 12 months of history and spending more than €5,000.
--  2. Regular: Customers with at least 12 months of history but spending €5,000 or less.
--  3. New: Customers with a lifespan less than 12 months.
-- And find the total number of customers by each group

WITH customer_record AS (
SELECT 
    c.customer_key,
    SUM(sales_amount) AS total_spending,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM fact_sales f
LEFT JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY customer_key
ORDER BY customer_key
)
SELECT
    CASE 
	WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
    END AS cust_group,
    COUNT(customer_key) as total_customers
FROM customer_record
GROUP BY cust_group
ORDER BY total_customers;
