-- 02_joins_aggregates.sql
-- JOINs + Aggregates: INNER, LEFT, COUNT, SUM, AVG, GROUP BY, HAVING, COUNT DISTINCT, ROUND, COALESCE, GROUP BY multi, MIN/MAX

-- 1. INNER JOIN orders + dark_stores (6000 rows, excludes no-store)
SELECT o.order_id, ds.store_name, ds.cluster
FROM orders AS o
INNER JOIN dark_stores AS ds ON o.store_id = ds.store_id;

-- 2. LEFT JOIN dark_stores -> orders (shows Powai Annex not yet live with 0 orders)
SELECT ds.store_name, ds.cluster, COUNT(o.order_id) AS order_count
FROM dark_stores AS ds
LEFT JOIN orders AS o ON o.store_id = ds.store_id
GROUP BY ds.store_id, ds.store_name, ds.cluster;

-- 3. COUNT by status (Delivered 5616, Cancelled 384)
SELECT status, COUNT(*) AS n_orders
FROM orders
GROUP BY status;

-- 4. SUM(within_sla) + AVG(within_sla) = % within SLA (Delivered only)
SELECT
    SUM(within_sla) AS orders_within_sla,
    AVG(within_sla) AS pct_within_sla
FROM orders
WHERE status = 'Delivered';

-- 5. GROUP BY cluster (with JOIN)
SELECT ds.cluster, COUNT(*) AS n_orders
FROM orders AS o
JOIN dark_stores AS ds ON o.store_id = ds.store_id
GROUP BY ds.cluster;

-- 6. HAVING (clusters with > 1000 orders)
SELECT ds.cluster, COUNT(*) AS n_orders
FROM orders AS o
JOIN dark_stores AS ds ON o.store_id = ds.store_id
GROUP BY ds.cluster
HAVING COUNT(*) > 1000;

-- 7. COUNT(DISTINCT store_id) = 12 live stores (of 13 total)
SELECT COUNT(DISTINCT store_id) AS live_stores
FROM orders;

-- 8. ROUND(AVG(delivery_minutes), 2) by category (Delivered)
SELECT
    category,
    ROUND(AVG(delivery_minutes), 2) AS avg_mins
FROM orders
WHERE status = 'Delivered'
GROUP BY category;

-- 9. COALESCE for LEFT JOIN NULLs (Powai Annex shows 0)
SELECT
    ds.store_name,
    COALESCE(COUNT(o.order_id), 0) AS order_count
FROM dark_stores AS ds
LEFT JOIN orders AS o ON o.store_id = ds.store_id
GROUP BY ds.store_id, ds.store_name;

-- 10. GROUP BY category + hour band (multi-column)
SELECT
    o.category,
    hb.band,
    COUNT(*) AS n_orders
FROM orders AS o
JOIN hour_bands AS hb ON hb.hour_text = SUBSTR(o.order_ts, 12, 2)
GROUP BY o.category, hb.band
ORDER BY o.category, hb.band;

-- 11. MIN / MAX delivery_minutes (Delivered)
SELECT
    MIN(delivery_minutes) AS min_mins,
    MAX(delivery_minutes) AS max_mins
FROM orders
WHERE status = 'Delivered';
