-- Sample Data Generation Script for Lab 17
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    amount DECIMAL(10,2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Populate 100,000 customers
INSERT INTO customers (name, email)
SELECT 
    'Customer ' || generate_series,
    'customer' || generate_series || '@example.com'
FROM generate_series(1, 100000);

-- Populate 500,000 orders
INSERT INTO orders (customer_id, amount)
SELECT 
    (random() * 100000)::integer + 1,
    (random() * 1000)::decimal(10,2)
FROM generate_series(1, 500000);

-- Create performance indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Update query planner statistics
ANALYZE customers;
ANALYZE orders;
