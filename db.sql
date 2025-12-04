-- таблиця товарів
CREATE TABLE products1 (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC(10,2) CHECK (price >= 0)
);

-- таблиця клієнтів
CREATE TABLE customers1 (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  city TEXT
);

-- таблиця замовлень
CREATE TABLE orders1 (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER 
  REFERENCES customers1(id) ON DELETE CASCADE,
  order_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- таблиця позицій у замовленні
CREATE TABLE orders_items1 (
  order_id INTEGER 
  REFERENCES orders1(id) ON DELETE CASCADE,
  product_id INTEGER 
  REFERENCES products1(id) ON DELETE CASCADE,
  quantity INTEGER CHECK (quantity > 0),
  PRIMARY KEY (order_id, product_id)
);

-- Додаємо товари
INSERT INTO products1 (name, category, price) VALUES 
  ('Notebook', 'Electronics', 1200.00),
  ('Mouse', 'Electronics', 25.50),
  ('T-Shirt', 'Clothing', 10.00),  
  ('Chair', 'Furniture', 15.25),
  ('Water', 'Food', 2.00);

INSERT INTO customers1 (name, email, city) VALUES 
  ('Svitlana', 'svitlana@example.com', 'Kyiv'),  
  ('Taras', 'taras@example.com', 'Lviv'),
  ('Iryna', 'iryna@example.com', 'Odesa');

INSERT INTO orders1 (customer_id) VALUES (1);
INSERT INTO orders1 (customer_id) VALUES (3);
INSERT INTO orders1 (customer_id) VALUES (3);

INSERT INTO orders_items1 (order_id, product_id, quantity) VALUES
  (1, 1, 1),
  (1, 2, 1),
  (2, 3, 1),
  (3, 5, 2);


-- CRUD операції для таблиці products1
--CREATE
INSERT INTO products1 (name, category, price) VALUES
('Keyboard','Electronics', 15.00);
--READ
SELECT * FROM products1;
--UPDATE
UPDATE products1 SET price = 14.99 WHERE name = 'Keyboard';
--DELETE
DELETE FROM products1 WHERE name = 'Keyboard';

--Побудуйте звіти:
--1.Кількість замовлень по клієнтах.
SELECT c.name, COUNT(o.id) AS orders_count
FROM customers1 c
LEFT JOIN orders1 o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY orders_count DESC;
--2.Сумарна вартість кожного замовлення.
SELECT 
  o.id AS order_id, 
  SUM(oi.quantity * p.price) AS order_total
FROM orders1 o
JOIN orders_items1 oi ON oi.order_id = o.id
JOIN products1 p ON p.id = oi.product_id
GROUP BY o.id
ORDER BY order_total DESC;
--3.Топ‑3 найдорожчі товари.
SELECT name, price 
FROM products1
ORDER BY price DESC
LIMIT 3;
---------------------------
SELECT category, name, price 
FROM (
  SELECT category, name, price,
  ROW_NUMBER() OVER (PARTITION by category ORDER BY price DESC) AS rank_in_category
  FROM products1
) ranked
WHERE rank_in_category <= 3
ORDER BY category, price DESC;

--Використайте транзакцію для створення замовлення з кількома товарами.
BEGIN;
INSERT INTO orders1 (customer_id) VALUES (2);
INSERT INTO orders_items1 (order_id, product_id, quantity) 
VALUES
(4, 2, 3),
(4, 5, 2),
(4, 4, 1);
COMMIT; 

--Створіть view, яке показує кількість замовлень і витрати клієнтів.
CREATE OR REPLACE VIEW vw_customer_orders_count AS
SELECT 
    c.name, 
    COUNT(DISTINCT o.id) AS order_count, 
    SUM(oi.quantity * p.price), 0.00 AS total_price 
FROM customers1 c
LEFT JOIN orders1 o ON o.customer_id = c.id
LEFT JOIN orders_items1 oi on oi.order_id = o.id
LEFT JOIN products1 p on p.id = oi.product_id
GROUP BY c.name
ORDER BY order_count DESC;

SELECT * FROM vw_customer_orders_count;