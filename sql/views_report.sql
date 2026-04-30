
-- Purpose: Create reusable reporting views.


CREATE OR REPLACE VIEW vw_customer_360 AS
WITH order_summary AS (
    SELECT
        customer_id,
        COUNT(*) FILTER (WHERE order_status = 'Completed') AS completed_orders,
        SUM(total_amount) FILTER (WHERE order_status = 'Completed') AS lifetime_value,
        MIN(order_date) FILTER (WHERE order_status = 'Completed') AS first_order_date,
        MAX(order_date) FILTER (WHERE order_status = 'Completed') AS last_order_date
    FROM orders
    GROUP BY customer_id
),
activity_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_activities,
        MAX(activity_date) AS last_activity_date
    FROM customer_activity
    GROUP BY customer_id
),
support_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS support_tickets,
        COUNT(*) FILTER (WHERE resolution_status IN ('Unresolved','Escalated')) AS problem_tickets,
        ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score
    FROM support_tickets
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.full_name,
    c.gender,
    c.age,
    c.city,
    c.state,
    c.signup_date,
    c.acquisition_channel,
    c.customer_segment,
    COALESCE(os.completed_orders, 0) AS completed_orders,
    COALESCE(os.lifetime_value, 0) AS lifetime_value,
    os.first_order_date,
    os.last_order_date,
    CASE
        WHEN os.last_order_date IS NULL THEN NULL
        ELSE CURRENT_DATE - os.last_order_date
    END AS days_since_last_order,
    COALESCE(a.total_activities, 0) AS total_activities,
    a.last_activity_date,
    COALESCE(s.support_tickets, 0) AS support_tickets,
    COALESCE(s.problem_tickets, 0) AS problem_tickets,
    s.avg_satisfaction_score
FROM customers c
LEFT JOIN order_summary os ON c.customer_id = os.customer_id
LEFT JOIN activity_summary a ON c.customer_id = a.customer_id
LEFT JOIN support_summary s ON c.customer_id = s.customer_id;

CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_TRUNC('month', order_date)::DATE AS revenue_month,
    COUNT(DISTINCT customer_id) AS paying_customers,
    COUNT(*) AS completed_orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)::DATE;
