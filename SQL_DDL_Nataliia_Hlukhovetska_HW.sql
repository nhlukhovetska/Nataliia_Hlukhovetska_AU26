-- Task: create a physical DB
-- Database: ecommerce_db
-- Schema: marketplace
-- Step 1: Create a separate physical database and schema
-- Note: Executing CREATE DATABASE usually requires running outside of a transaction block.
-- CREATE DATABASE ecommerce_db;
-- \c ecommerce_db;

CREATE SCHEMA IF NOT EXISTS marketplace;


-- Сreate tables 
set search_path to marketpace
CREATE TABLE IF NOT EXISTS addresses (
address_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
country VARCHAR(50) NOT null,
city VARCHAR(50) NOT null,
street VARCHAR(50) NOT null,
building VARCHAR(50) NOT null,
apartment INT,
postal_code VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS customers (
customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
first_name VARCHAR(50) NOT NULL, 
last_name VARCHAR(50) NOT NULL, 
email VARCHAR(254) UNIQUE, 
phone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS categories (
category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
category_name VARCHAR(50) NOT null,
description TEXT
);

CREATE TABLE IF NOT EXISTS payment_method (
payment_method_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
name VARCHAR(50)NOT null
);

CREATE TABLE IF NOT EXISTS order_status (
status_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
status_name VARCHAR(50) NOT NULL,

CONSTRAINT chk_status_name CHECK (status_name IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))

);

CREATE TABLE IF NOT EXISTS couriers (
courier_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
first_name VARCHAR(50)NOT NULL,
last_name VARCHAR(50)NOT NULL,
phone VARCHAR(50)NOT NULL
);

CREATE TABLE IF NOT EXISTS delivery_method (
delivery_method_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
delivery_method_name VARCHAR(50)NOT NULL
);


CREATE TABLE IF NOT EXISTS sellers (
seller_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
seller_name VARCHAR(50)NOT NULL,
seller_addresses_id INT REFERENCES addresses(address_id)
);

CREATE TABLE IF NOT EXISTS products (
product_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
product_name VARCHAR(50)NOT NULL,
seller_id INT REFERENCES sellers(seller_id)
);

CREATE TABLE IF NOT EXISTS payments (
payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
amount DECIMAL(8, 2),
payment_method_id INT REFERENCES payment_method(payment_method_id),
paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- CONSTRAINT : Value cannot be negative
CONSTRAINT chk_amount_positive CHECK (amount >= 0)
);

CREATE TABLE IF NOT EXISTS orders (
order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
customer_id INT REFERENCES customers(customer_id),
order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
payment_id INT REFERENCES payments(payment_id),
-- CONSTRAINT : Date must be greater than Jan 1, 2000
CONSTRAINT chk_order_date CHECK (order_date > '2000-01-01')
);


CREATE TABLE IF NOT EXISTS Product_categories (
product_id INT REFERENCES products(product_id),
categories_id INT REFERENCES categories(category_id),
PRIMARY KEY (product_id, categories_id)
);

CREATE TABLE IF NOT EXISTS order_items (
order_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
order_id INT REFERENCES orders(order_id),
product_id INT REFERENCES products(product_id),
unit_price DECIMAL(8, 2)NOT NULL,
quantity INT,
-- CONSTRAINT : Values cannot be negative
CONSTRAINT chk_unit_price_positive CHECK (unit_price >= 0),
CONSTRAINT chk_quantity_positive CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS order_status_history (
status_history_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
order_status_id INT REFERENCES order_status(status_id),
order_id INT REFERENCES orders(order_id),
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS deliveries (
delivery_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
courier_id INT REFERENCES couriers(courier_id),
delivery_method_id INT REFERENCES delivery_method(delivery_method_id),
delivery_address_id INT REFERENCES addresses(address_id),
order_id INT REFERENCES orders(order_id)
);

--Populate tables with sample data (20+ rows total)

INSERT INTO addresses (country, city, street, building, apartment, postal_code)
SELECT 'Ukraine', 'Kyiv', 'Khreshchatyk', '22', 25, '01001'
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE postal_code = '01001');

INSERT INTO addresses (country, city, street, building, apartment, postal_code)
SELECT 'Ukraine', 'Lviv', 'Rynok Square', '2', 7, '79000'
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE postal_code = '79000');

INSERT INTO addresses (country, city, street, building, apartment, postal_code)
SELECT 'USA', 'New York', 'Broadway', '98', 8, '10001'
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE postal_code = '10001');

INSERT INTO addresses (country, city, street, building, apartment, postal_code)
SELECT 'Germany', 'Berlin', 'Unter den Linden', '69', 12, '10117'
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE postal_code = '10117');


INSERT INTO customers (first_name, last_name, email, phone)
SELECT 'Sofia', 'Brown', 'sofiabrown@gmail.com', '+380504354727'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE email = 'sofiabrown@gmail.com');

INSERT INTO customers (first_name, last_name, email, phone)
SELECT 'Taras', 'Taneka', 'taneka@gmail.com', '+380671234567'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE email = 'taneka@gmail.com');

INSERT INTO customers (first_name, last_name, email, phone)
SELECT 'Leya', 'Vaska', 'vaskaleya@gmail.com', '+3806629462857'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE email = 'vaskaleya@gmail.com');

INSERT INTO categories (category_name, description)
SELECT 'Electronics', 'Phones, laptops, etc.'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE category_name = 'Electronics');

INSERT INTO categories (category_name, description)
SELECT 'Clothing', 'Apparel and accessories for women, men and children'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE category_name = 'Clothing');

INSERT INTO categories (category_name, description)
SELECT 'Books', 'Fiction and non-fiction'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE category_name = 'Books');

INSERT INTO categories (category_name, description)
SELECT 'Home', 'Furniture and decor for home'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE category_name = 'Home');


INSERT INTO payment_method (name)
SELECT 'Card' WHERE NOT EXISTS (SELECT 1 FROM payment_method WHERE name = 'Card');

INSERT INTO payment_method (name)
SELECT 'Cash' WHERE NOT EXISTS (SELECT 1 FROM payment_method WHERE name = 'Cash');

INSERT INTO payment_method (name)
SELECT 'Online payment' WHERE NOT EXISTS (SELECT 1 FROM payment_method WHERE name = 'Online payment');


INSERT INTO order_status (status_name)
SELECT 'Pending' WHERE NOT EXISTS (SELECT 1 FROM order_status WHERE status_name = 'Pending');

INSERT INTO order_status (status_name)
SELECT 'Delivered' WHERE NOT EXISTS (SELECT 1 FROM order_status WHERE status_name = 'Delivered');

INSERT INTO order_status (status_name)
SELECT 'Shipped' WHERE NOT EXISTS (SELECT 1 FROM order_status WHERE status_name = 'Shipped');

INSERT INTO couriers (first_name, last_name, phone)
SELECT 'Petro', 'Karvan', '+380935115133'
WHERE NOT EXISTS (SELECT 1 FROM couriers WHERE phone = '+380935115133');

INSERT INTO couriers (first_name, last_name, phone)
SELECT 'Maria', 'Yarych', '+380875345566'
WHERE NOT EXISTS (SELECT 1 FROM couriers WHERE phone = '+380875345566');

INSERT INTO delivery_method (delivery_method_name)
SELECT 'Nova Poshta' WHERE NOT EXISTS (SELECT 1 FROM delivery_method WHERE delivery_method_name = 'Nova Poshta');

INSERT INTO delivery_method (delivery_method_name)
SELECT 'Ukrposhta' WHERE NOT EXISTS (SELECT 1 FROM delivery_method WHERE delivery_method_name = 'Ukrposhta');

INSERT INTO sellers (seller_name, seller_addresses_id)
SELECT 'Tech Store', (SELECT address_id FROM addresses WHERE postal_code = '01001' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM sellers WHERE seller_name = 'Tech Store');

INSERT INTO sellers (seller_name, seller_addresses_id)
SELECT 'Book Shop', (SELECT address_id FROM addresses WHERE postal_code = '79000' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM sellers WHERE seller_name = 'Book Shop');

INSERT INTO products (product_name, seller_id)
SELECT 'Laptop', (SELECT seller_id FROM sellers WHERE seller_name = 'Tech Store' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM products WHERE product_name = 'Laptop');

INSERT INTO products (product_name, seller_id)
SELECT 'Novel', (SELECT seller_id FROM sellers WHERE seller_name = 'Book Shop' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM products WHERE product_name = 'Novel');

INSERT INTO Product_categories (product_id, categories_id)
SELECT p.product_id, c.category_id
FROM products p, categories c
WHERE p.product_name = 'Laptop' AND c.category_name = 'Electronics'
AND NOT EXISTS (
SELECT 1 FROM Product_categories pc
WHERE pc.product_id = p.product_id AND pc.categories_id = c.category_id
);

INSERT INTO payments (amount, payment_method_id)
SELECT 1500.00, (SELECT payment_method_id FROM payment_method WHERE name = 'Credit Card' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM payments WHERE amount = 1500.00);

INSERT INTO payments (amount, payment_method_id)
SELECT 25.50, (SELECT payment_method_id FROM payment_method WHERE name = 'PayPal' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM payments WHERE amount = 25.50);

INSERT INTO orders (customer_id, payment_id)
SELECT
(SELECT customer_id FROM customers WHERE email = 'ivan@example.com' LIMIT 1),
(SELECT payment_id FROM payments WHERE amount = 1500.00 LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE customer_id = 1);

INSERT INTO orders (customer_id, payment_id)
SELECT
(SELECT customer_id FROM customers WHERE email = 'lesya@example.com' LIMIT 1),
(SELECT payment_id FROM payments WHERE amount = 25.50 LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE customer_id = 2);

INSERT INTO order_items (order_id, product_id, unit_price, quantity)
SELECT
(SELECT order_id FROM orders ORDER BY order_id LIMIT 1),
(SELECT product_id FROM products WHERE product_name = 'Laptop' LIMIT 1),
1500.00, 1
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = 1 AND product_id = 1);

INSERT INTO order_status_history (order_status_id, order_id)
SELECT
(SELECT status_id FROM order_status WHERE status_name = 'Pending' LIMIT 1),
(SELECT order_id FROM orders ORDER BY order_id LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = 1);

INSERT INTO deliveries (courier_id, delivery_method_id, delivery_address_id, order_id)
SELECT
(SELECT courier_id FROM couriers WHERE first_name = 'Petro' LIMIT 1),
(SELECT delivery_method_id FROM delivery_method WHERE delivery_method_name = 'Nova Poshta' LIMIT 1),
(SELECT address_id FROM addresses WHERE postal_code = '01001' LIMIT 1),
(SELECT order_id FROM orders ORDER BY order_id LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM deliveries WHERE order_id = 1);


-- Add the column with a DEFAULT value so existing rows are automatically populated.

ALTER TABLE addresses ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE categories ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE payment_method ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE order_status ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE couriers ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE delivery_method ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE sellers ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE Product_categories ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE order_status_history ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE deliveries ADD COLUMN IF NOT EXISTS record_ts DATE NOT NULL DEFAULT CURRENT_DATE;
