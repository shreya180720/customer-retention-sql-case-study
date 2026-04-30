
-- Insert sample data for SQL analytics.

INSERT INTO customers (
    full_name,
    gender,
    age,
    city,
    state,
    signup_date,
    acquisition_channel,
    customer_segment
)
SELECT
    'Customer ' || gs AS full_name,
    CASE
        WHEN random() < 0.48 THEN 'Female'
        WHEN random() < 0.96 THEN 'Male'
        ELSE 'Other'
    END AS gender,
    FLOOR(18 + random() * 47)::INT AS age,
    (ARRAY['Tampa','Orlando','Miami','Atlanta','Dallas','Austin','Phoenix','Seattle','Chicago','New York'])[FLOOR(1 + random() * 10)::INT],
    (ARRAY['FL','FL','FL','GA','TX','TX','AZ','WA','IL','NY'])[FLOOR(1 + random() * 10)::INT],
    DATE '2024-01-01' + FLOOR(random() * 540)::INT,
    (ARRAY['Organic Search','Paid Ads','Referral','Social Media','Email Campaign'])[FLOOR(1 + random() * 5)::INT],
    (ARRAY['Standard','Premium','Enterprise'])[FLOOR(1 + random() * 3)::INT]
FROM generate_series(1, 500) gs;

INSERT INTO products (product_name, category, unit_price)
VALUES
('Starter Plan', 'Subscription', 29.00),
('Pro Plan', 'Subscription', 79.00),
('Enterprise Plan', 'Subscription', 249.00),
('Analytics Add-on', 'Add-on', 49.00),
('Automation Add-on', 'Add-on', 69.00),
('Data Export Pack', 'Add-on', 39.00),
('Training Session', 'Service', 149.00),
('Implementation Support', 'Service', 299.00),
('Premium Support', 'Service', 199.00),
('API Access', 'Subscription', 99.00);


INSERT INTO orders (customer_id, order_date, order_status, total_amount)
SELECT
    c.customer_id,
    c.signup_date + FLOOR(random() * 420)::INT AS order_date,
    CASE
        WHEN random() < 0.88 THEN 'Completed'
        WHEN random() < 0.95 THEN 'Cancelled'
        ELSE 'Refunded'
    END AS order_status,
    0.00 AS total_amount
FROM customers c
JOIN generate_series(1, 8) n ON random() < 0.42;


INSERT INTO orders (customer_id, order_date, order_status, total_amount)
SELECT
    c.customer_id,
    c.signup_date + FLOOR(random() * 45)::INT,
    'Completed',
    0.00
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
)
AND random() < 0.85;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.order_id,
    p.product_id,
    FLOOR(1 + random() * 3)::INT AS quantity,
    p.unit_price
FROM orders o
JOIN generate_series(1, 3) n ON random() < 0.65
JOIN LATERAL (
    SELECT product_id, unit_price
    FROM products
    ORDER BY random()
    LIMIT 1
) p ON true;


UPDATE orders o
SET total_amount = sub.order_total
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) sub
WHERE o.order_id = sub.order_id;

-- Payments data
INSERT INTO payments (order_id, payment_date, payment_method, payment_status)
SELECT
    order_id,
    order_date,
    (ARRAY['Credit Card','Debit Card','PayPal','Bank Transfer'])[FLOOR(1 + random() * 4)::INT],
    CASE
        WHEN order_status = 'Completed' THEN 'Paid'
        WHEN order_status = 'Refunded' THEN 'Refunded'
        ELSE 'Failed'
    END
FROM orders;

-- Activity data.
INSERT INTO customer_activity (customer_id, activity_date, activity_type)
SELECT
    c.customer_id,
    c.signup_date + FLOOR(random() * 500)::INT,
    (ARRAY['Login','Product View','Cart Add','Feature Use','Email Click','Dashboard View'])[FLOOR(1 + random() * 6)::INT]
FROM customers c
JOIN generate_series(1, 15) n ON random() < 0.55;

-- Support tickets.
INSERT INTO support_tickets (
    customer_id,
    created_date,
    issue_type,
    resolution_status,
    satisfaction_score
)
SELECT
    c.customer_id,
    c.signup_date + FLOOR(random() * 420)::INT,
    (ARRAY['Billing Issue','Technical Issue','Account Access','Product Question','Cancellation Request'])[FLOOR(1 + random() * 5)::INT],
    CASE
        WHEN random() < 0.75 THEN 'Resolved'
        WHEN random() < 0.90 THEN 'Escalated'
        ELSE 'Unresolved'
    END,
    FLOOR(1 + random() * 5)::INT
FROM customers c
JOIN generate_series(1, 3) n ON random() < 0.24;

ANALYZE;
