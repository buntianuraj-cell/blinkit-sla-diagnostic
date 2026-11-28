-- 01_foundations.sql
-- Foundations: WHERE, DISTINCT, LIKE, ORDER BY, BETWEEN, IS NULL, alias, ORDER BY + LIMIT, string functions

-- 1. SELECT one column + WHERE (Delivered only, 5616 rows)
SELECT order_id
FROM orders
WHERE status = 'Delivered';

-- 2. DISTINCT categories (5 rows)
SELECT DISTINCT category
FROM orders;

-- 3. LIKE for Mumbai clusters (Andheri, Powai, Thane) via dark_stores join
SELECT o.order_id, ds.cluster
FROM orders AS o
JOIN dark_stores AS ds ON o.store_id = ds.store_id
WHERE ds.cluster LIKE 'A%'
   OR ds.cluster LIKE 'P%'
   OR ds.cluster LIKE 'T%';

-- 4. ORDER BY latest orders (order_ts DESC, 10 rows) + LIMIT
SELECT order_id, order_ts, category, status
FROM orders
ORDER BY order_ts DESC
LIMIT 10;

-- 5. BETWEEN for delivery time (Delivered, delivery_minutes BETWEEN 10 AND 20)
SELECT order_id, delivery_minutes
FROM orders
WHERE status = 'Delivered'
  AND delivery_minutes BETWEEN 10 AND 20;

-- 6. IS NULL for Cancelled (384 rows)
SELECT order_id, status, delivery_minutes, within_sla
FROM orders
WHERE delivery_minutes IS NULL;

-- 7. Aliases for 4 columns
SELECT
    order_id AS id,
    order_ts AS ordered_at,
    delivery_minutes AS mins,
    within_sla AS met_sla
FROM orders;

-- 8. ORDER BY + LIMIT for slowest orders (Delivered, top 10 slowest)
SELECT order_id, delivery_minutes
FROM orders
WHERE status = 'Delivered'
ORDER BY delivery_minutes DESC
LIMIT 10;

-- 9. String functions on category (UPPER + LENGTH)
SELECT
    category,
    UPPER(category) AS category_upper,
    LENGTH(category) AS category_len
FROM orders
LIMIT 10;
