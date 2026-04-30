
-- Database: PostgreSQL 17

DROP TABLE IF EXISTS support_tickets CASCADE;
DROP TABLE IF EXISTS customer_activity CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    age INT CHECK (age >= 18),
    city VARCHAR(80),
    state VARCHAR(80),
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(30) DEFAULT 'Standard'
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL CHECK (order_status IN ('Completed', 'Cancelled', 'Refunded')),
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(40) NOT NULL,
    payment_status VARCHAR(30) NOT NULL CHECK (payment_status IN ('Paid', 'Failed', 'Refunded'))
);

CREATE TABLE customer_activity (
    activity_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    activity_date DATE NOT NULL,
    activity_type VARCHAR(50) NOT NULL
);

CREATE TABLE support_tickets (
    ticket_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    created_date DATE NOT NULL,
    issue_type VARCHAR(80) NOT NULL,
    resolution_status VARCHAR(30) NOT NULL CHECK (resolution_status IN ('Resolved', 'Unresolved', 'Escalated')),
    satisfaction_score INT CHECK (satisfaction_score BETWEEN 1 AND 5)
);

CREATE INDEX idx_customers_signup_date ON customers(signup_date);
CREATE INDEX idx_customers_channel ON customers(acquisition_channel);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_activity_customer_date ON customer_activity(customer_id, activity_date);
CREATE INDEX idx_support_customer_id ON support_tickets(customer_id);
