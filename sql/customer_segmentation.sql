-- Customer segmentation using RFM and business rules.
------------------------------------------------------------------

-- Q16. RFM segmentation: recency, frequency, monetary value.
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.acquisition_channel,
        MAX(o.order_date) AS last_order_date,
        COUNT(o.order_id) AS frequency,
        SUM(o.total_amount) AS monetary_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.full_name, c.acquisition_channel
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY last_order_date ASC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
)
SELECT
    customer_id,
    full_name,
    acquisition_channel,
    last_order_date,
    frequency,
    ROUND(monetary_value, 2) AS monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS total_rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score <= 2 AND frequency_score >= 4 THEN 'At Risk High Frequency'
        WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'At Risk High Value'
        WHEN frequency_score <= 2 AND monetary_score <= 2 THEN 'Low Value'
        ELSE 'Needs Attention'
    END AS rfm_segment
FROM rfm_scores
ORDER BY total_rfm_score DESC;

-- Q17. Customer value tiers.
WITH customer_ltv AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.customer_segment,
        c.acquisition_channel,
        COUNT(o.order_id) AS orders,
        SUM(o.total_amount) AS lifetime_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.full_name, c.customer_segment, c.acquisition_channel
)
SELECT
    *,
    CASE
        WHEN lifetime_value >= 1000 THEN 'High Value'
        WHEN lifetime_value >= 400 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_tier
FROM customer_ltv
ORDER BY lifetime_value DESC;

-- Q18. Loyal customers with frequent repeat orders.
SELECT
    c.customer_id,
    c.full_name,
    c.acquisition_channel,
    COUNT(o.order_id) AS completed_orders,
    ROUND(SUM(o.total_amount), 2) AS lifetime_value,
    MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.full_name, c.acquisition_channel
HAVING COUNT(o.order_id) >= 5
ORDER BY lifetime_value DESC;

-- Q19. Product category preference by customer segment.
SELECT
    c.customer_segment,
    p.category,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(oi.quantity) AS units,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_segment, p.category
ORDER BY c.customer_segment, revenue DESC;
