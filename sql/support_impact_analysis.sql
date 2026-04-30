
-- Q20. Do customers with unresolved support tickets spend less or churn more?
WITH customer_purchase_summary AS (
    SELECT
        c.customer_id,
        COUNT(o.order_id) FILTER (WHERE o.order_status = 'Completed') AS completed_orders,
        SUM(o.total_amount) FILTER (WHERE o.order_status = 'Completed') AS lifetime_value,
        MAX(o.order_date) FILTER (WHERE o.order_status = 'Completed') AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
support_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_tickets,
        COUNT(*) FILTER (WHERE resolution_status IN ('Unresolved', 'Escalated')) AS problem_tickets,
        ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score
    FROM support_tickets
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN ss.problem_tickets > 0 THEN 'Has unresolved/escalated tickets'
        WHEN ss.total_tickets > 0 THEN 'Only resolved tickets'
        ELSE 'No support tickets'
    END AS support_group,
    COUNT(cps.customer_id) AS customers,
    ROUND(AVG(cps.completed_orders), 2) AS avg_completed_orders,
    ROUND(AVG(COALESCE(cps.lifetime_value, 0)), 2) AS avg_lifetime_value,
    ROUND(AVG(CURRENT_DATE - cps.last_order_date), 1) AS avg_days_since_last_order,
    ROUND(AVG(ss.avg_satisfaction_score), 2) AS avg_satisfaction_score
FROM customer_purchase_summary cps
LEFT JOIN support_summary ss ON cps.customer_id = ss.customer_id
GROUP BY support_group
ORDER BY avg_lifetime_value DESC;

-- Q21. Does satisfaction score affect repeat purchase behavior?
WITH support_customer AS (
    SELECT
        customer_id,
        ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score
    FROM support_tickets
    WHERE satisfaction_score IS NOT NULL
    GROUP BY customer_id
),
purchase_summary AS (
    SELECT
        customer_id,
        COUNT(*) FILTER (WHERE order_status = 'Completed') AS completed_orders,
        SUM(total_amount) FILTER (WHERE order_status = 'Completed') AS lifetime_value
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN sc.avg_satisfaction_score >= 4 THEN 'High Satisfaction'
        WHEN sc.avg_satisfaction_score >= 3 THEN 'Medium Satisfaction'
        ELSE 'Low Satisfaction'
    END AS satisfaction_group,
    COUNT(*) AS customers,
    ROUND(AVG(ps.completed_orders), 2) AS avg_completed_orders,
    ROUND(AVG(ps.lifetime_value), 2) AS avg_lifetime_value,
    ROUND(100.0 * COUNT(*) FILTER (WHERE ps.completed_orders >= 2) / NULLIF(COUNT(*), 0), 2) AS repeat_customer_rate_percent
FROM support_customer sc
JOIN purchase_summary ps ON sc.customer_id = ps.customer_id
GROUP BY satisfaction_group
ORDER BY repeat_customer_rate_percent DESC;

-- Q22. Which issue types are most associated with low satisfaction?
SELECT
    issue_type,
    COUNT(*) AS ticket_count,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
    COUNT(*) FILTER (WHERE resolution_status IN ('Unresolved', 'Escalated')) AS unresolved_or_escalated_tickets
FROM support_tickets
GROUP BY issue_type
ORDER BY avg_satisfaction_score ASC, ticket_count DESC;
