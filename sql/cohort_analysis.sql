--Cohort retention and revenue analysis.
---------------------------------------------------------------------

-- Q13. Cohort analysis by first purchase month.
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::DATE AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
customer_monthly_orders AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        SUM(o.total_amount) AS revenue
    FROM orders o
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id, DATE_TRUNC('month', o.order_date)::DATE
),
cohort_data AS (
    SELECT
        fp.cohort_month,
        cmo.order_month,
        (
            EXTRACT(YEAR FROM AGE(cmo.order_month, fp.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(cmo.order_month, fp.cohort_month))
        )::INT AS months_since_first_purchase,
        COUNT(DISTINCT cmo.customer_id) AS active_customers,
        SUM(cmo.revenue) AS cohort_revenue
    FROM first_purchase fp
    JOIN customer_monthly_orders cmo ON fp.customer_id = cmo.customer_id
    GROUP BY fp.cohort_month, cmo.order_month
)
SELECT
    cohort_month,
    months_since_first_purchase,
    active_customers,
    ROUND(cohort_revenue, 2) AS cohort_revenue
FROM cohort_data
ORDER BY cohort_month, months_since_first_purchase;

-- Q14. Cohort retention percentage.
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::DATE AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
activity_by_month AS (
    SELECT DISTINCT
        fp.cohort_month,
        o.customer_id,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        (
            EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_date), fp.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), fp.cohort_month))
        )::INT AS month_number
    FROM first_purchase fp
    JOIN orders o ON fp.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    abm.cohort_month,
    abm.month_number,
    COUNT(DISTINCT abm.customer_id) AS retained_customers,
    cs.cohort_customers,
    ROUND(100.0 * COUNT(DISTINCT abm.customer_id) / NULLIF(cs.cohort_customers, 0), 2) AS retention_percent
FROM activity_by_month abm
JOIN cohort_size cs ON abm.cohort_month = cs.cohort_month
GROUP BY abm.cohort_month, abm.month_number, cs.cohort_customers
ORDER BY abm.cohort_month, abm.month_number;

-- Q15. 30-day, 60-day, and 90-day retention by acquisition channel.
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
future_purchases AS (
    SELECT
        fp.customer_id,
        c.acquisition_channel,
        fp.first_purchase_date,
        MAX(CASE WHEN o.order_date > fp.first_purchase_date AND o.order_date <= fp.first_purchase_date + INTERVAL '30 days' THEN 1 ELSE 0 END) AS retained_30d,
        MAX(CASE WHEN o.order_date > fp.first_purchase_date AND o.order_date <= fp.first_purchase_date + INTERVAL '60 days' THEN 1 ELSE 0 END) AS retained_60d,
        MAX(CASE WHEN o.order_date > fp.first_purchase_date AND o.order_date <= fp.first_purchase_date + INTERVAL '90 days' THEN 1 ELSE 0 END) AS retained_90d
    FROM first_purchase fp
    JOIN customers c ON fp.customer_id = c.customer_id
    LEFT JOIN orders o ON fp.customer_id = o.customer_id AND o.order_status = 'Completed'
    GROUP BY fp.customer_id, c.acquisition_channel, fp.first_purchase_date
)
SELECT
    acquisition_channel,
    COUNT(*) AS customers,
    ROUND(100.0 * SUM(retained_30d) / NULLIF(COUNT(*), 0), 2) AS retention_30d_percent,
    ROUND(100.0 * SUM(retained_60d) / NULLIF(COUNT(*), 0), 2) AS retention_60d_percent,
    ROUND(100.0 * SUM(retained_90d) / NULLIF(COUNT(*), 0), 2) AS retention_90d_percent
FROM future_purchases
GROUP BY acquisition_channel
ORDER BY retention_90d_percent DESC;
