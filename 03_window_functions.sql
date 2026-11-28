-- 03_window_functions.sql
-- Window Functions: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, AVG OVER, SUM OVER, NTILE, FIRST_VALUE

-- 1. ROW_NUMBER() latest order per cluster
SELECT *
FROM (
    SELECT
        o.order_id,
        ds.cluster,
        o.order_ts,
        ROW_NUMBER() OVER (PARTITION BY ds.cluster ORDER BY o.order_ts DESC) AS rn
    FROM orders AS o
    JOIN dark_stores AS ds ON o.store_id = ds.store_id
) WHERE rn = 1;

-- 2. RANK() slowest orders per category (Delivered)
SELECT
    order_id,
    category,
    delivery_minutes,
    RANK() OVER (PARTITION BY category ORDER BY delivery_minutes DESC) AS rnk
FROM orders
WHERE status = 'Delivered';

-- 3. DENSE_RANK() by cluster avg delivery time
SELECT
    ds.cluster,
    ROUND(AVG(o.delivery_minutes), 2) AS avg_mins,
    DENSE_RANK() OVER (ORDER BY AVG(o.delivery_minutes) DESC) AS drnk
FROM orders AS o
JOIN dark_stores AS ds ON o.store_id = ds.store_id
WHERE o.status = 'Delivered'
GROUP BY ds.cluster;

-- 4. LAG() previous order time per store (gap analysis)
SELECT
    order_id,
    store_id,
    order_ts,
    LAG(order_ts) OVER (PARTITION BY store_id ORDER BY order_ts) AS prev_order_ts
FROM orders;

-- 5. LEAD() next order time per store
SELECT
    order_id,
    store_id,
    order_ts,
    LEAD(order_ts) OVER (PARTITION BY store_id ORDER BY order_ts) AS next_order_ts
FROM orders;

-- 6. AVG() OVER() category average vs each order (Delivered)
SELECT
    order_id,
    category,
    delivery_minutes,
    ROUND(AVG(delivery_minutes) OVER (PARTITION BY category), 2) AS category_avg
FROM orders
WHERE status = 'Delivered';

-- 7. SUM() OVER() running total of orders per day
SELECT
    DATE(order_ts) AS order_date,
    COUNT(*) AS daily_orders,
    SUM(COUNT(*)) OVER (ORDER BY DATE(order_ts)) AS running_total
FROM orders
GROUP BY DATE(order_ts);

-- 8. NTILE(4) quartiles of delivery_minutes (Delivered)
SELECT
    order_id,
    delivery_minutes,
    NTILE(4) OVER (ORDER BY delivery_minutes) AS quartile
FROM orders
WHERE status = 'Delivered';

-- 9. FIRST_VALUE() fastest order per cluster
SELECT DISTINCT
    ds.cluster,
    FIRST_VALUE(o.order_id) OVER (PARTITION BY ds.cluster ORDER BY o.delivery_minutes ASC) AS fastest_order_id,
    FIRST_VALUE(o.delivery_minutes) OVER (PARTITION BY ds.cluster ORDER BY o.delivery_minutes ASC) AS fastest_mins
FROM orders AS o
JOIN dark_stores AS ds ON o.store_id = ds.store_id
WHERE o.status = 'Delivered';
