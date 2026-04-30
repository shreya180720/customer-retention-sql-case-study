-- Retention, churn, and repeat-purchase analytics.
--------------------------------------------------------------------------------

-- Q7. What percentage of customers return after their first purchase?
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(*) FILTER (WHERE order_status = 'Completed') AS completed_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_purchasing_customers,
    COUNT(*) FILTER (WHERE completed_orders >= 2) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE completed_orders >= 2) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_percent
FROM customer_order_counts
WHERE completed_orders >= 1;

-- Q8. What is the monthly customer retention rate?
WITH monthly_active AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::DATE AS order_month
    FROM orders
    WHERE order_status = 'Completed'
),
retention AS (
    SELECT
        current_month.order_month,
        COUNT(DISTINCT current_month.customer_id) AS active_customers,
        COUNT(DISTINCT previous_month.customer_id) AS retained_customers
    FROM monthly_active current_month
    LEFT JOIN monthly_active previous_month
        ON current_month.customer_id = previous_month.customer_id
        AND previous_month.order_month = current_month.order_month - INTERVAL '1 month'
    GROUP BY current_month.order_month
)
SELECT
    order_month,
    active_customers,
    retained_customers,
    ROUND(100.0 * retained_customers / NULLIF(active_customers, 0), 2) AS retention_rate_percent
FROM retention
ORDER BY order_month;

-- Q9. Which acquisition channel has the best repeat purchase rate?
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.acquisition_channel,
        COUNT(o.order_id) FILTER (WHERE o.order_status = 'Completed') AS completed_orders
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers,
    COUNT(*) FILTER (WHERE completed_orders >= 2) AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE completed_orders >= 2) / NULLIF(COUNT(*), 0), 2) AS repeat_rate_percent
FROM customer_orders
GROUP BY acquisition_channel
ORDER BY repeat_rate_percent DESC;

-- Q10. How many customers churned after only one completed order?
WITH completed_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        MAX(order_date) AS last_order_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS one_time_customers,
    ROUND(AVG(CURRENT_DATE - last_order_date), 1) AS avg_days_since_last_order
FROM completed_orders
WHERE order_count = 1;

-- Q11. Which customers are currently dormant for 90+ days?
WITH last_purchase AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.acquisition_channel,
        MAX(o.order_date) AS last_order_date,
        SUM(o.total_amount) AS lifetime_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.full_name, c.acquisition_channel
)
SELECT
    customer_id,
    full_name,
    acquisition_channel,
    last_order_date,
    CURRENT_DATE - last_order_date AS days_since_last_order,
    ROUND(lifetime_value, 2) AS lifetime_value
FROM last_purchase
WHERE CURRENT_DATE - last_order_date >= 90
ORDER BY lifetime_value DESC;

-- Q12. What is the average number of days between customer purchases?
WITH customer_orders AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
    FROM orders
    WHERE order_status = 'Completed'
)
SELECT
    ROUND(AVG(order_date - previous_order_date), 1) AS avg_days_between_purchases
FROM customer_orders
WHERE previous_order_date IS NOT NULL;
