-- Business-driven revenue analytics.
------------------------------------------------------------------------

-- Q1. What is the monthly revenue trend?
SELECT
    DATE_TRUNC('month', order_date)::DATE AS revenue_month,
    COUNT(DISTINCT order_id) AS completed_orders,
    COUNT(DISTINCT customer_id) AS paying_customers,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Completed'
GROUP BY 1
ORDER BY 1;

-- Q2. Which acquisition channels generate the most revenue?
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS completed_orders,
    ROUND(SUM(o.total_amount), 2) AS revenue,
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT c.customer_id), 0), 2) AS revenue_per_customer
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;

-- Q3. Who are the top 10 customers by lifetime value?
SELECT
    c.customer_id,
    c.full_name,
    c.acquisition_channel,
    c.customer_segment,
    COUNT(o.order_id) AS completed_orders,
    ROUND(SUM(o.total_amount), 2) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.full_name, c.acquisition_channel, c.customer_segment
ORDER BY lifetime_value DESC
LIMIT 10;

-- Q4. Which product categories drive the highest revenue?
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- Q5. What is month-over-month revenue growth?
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS revenue_month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT
    revenue_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY revenue_month), 2) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY revenue_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY revenue_month), 0),
        2
    ) AS mom_growth_percent
FROM monthly_revenue
ORDER BY revenue_month;

-- Q6. Which cities/states generate the most revenue?
SELECT
    c.state,
    c.city,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.total_amount), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.state, c.city
ORDER BY revenue DESC;
