-- 04_cte_subquery_case.sql
-- CTEs, Subqueries, CASE WHEN, UNION, EXISTS, DATE functions

-- 1. CTE: avg delivery by cluster, then filter slow clusters (> 15 mins)
WITH cluster_avg AS (
    SELECT ds.cluster, AVG(o.delivery_minutes) AS avg_mins
    FROM orders AS o
    JOIN dark_stores AS ds ON o.store_id = ds.store_id
    WHERE o.status = 'Delivered'
    GROUP BY ds.cluster
)
SELECT * FROM cluster_avg WHERE avg_mins > 15 ORDER BY avg_mins DESC;

-- 2. Subquery in WHERE: orders slower than overall avg (Delivered)
SELECT order_id, delivery_minutes
FROM orders
WHERE status = 'Delivered'
  AND delivery_minutes > (SELECT AVG(delivery_minutes) FROM orders WHERE status = 'Delivered');

-- 3. CASE WHEN: SLA buckets
SELECT
    order_id,
    delivery_minutes,
    CASE
        WHEN delivery_minutes <= 10 THEN 'Fast (<=10)'
        WHEN delivery_minutes <= 15 THEN 'On-time (11-15)'
        ELSE 'Late (>15)'
    END AS sla_bucket
FROM orders
WHERE status = 'Delivered';

-- 4. UNION: Delivered + Cancelled counts in one table
SELECT 'Delivered' AS status, COUNT(*) AS n FROM orders WHERE status = 'Delivered'
UNION ALL
SELECT 'Cancelled' AS status, COUNT(*) AS n FROM orders WHERE status = 'Cancelled';

-- 5. EXISTS: stores that have at least one Late order (>15 mins)
SELECT store_name, cluster
FROM dark_stores AS ds
WHERE EXISTS (
    SELECT 1 FROM orders AS o
    WHERE o.store_id = ds.store_id
      AND o.status = 'Delivered'
      AND o.delivery_minutes > 15
);

-- 6. DATE functions: orders by day + hour band
SELECT
    DATE(order_ts) AS order_date,
    SUBSTR(order_ts, 12, 2) AS hour_text,
    COUNT(*) AS n_orders
FROM orders
GROUP BY DATE(order_ts), SUBSTR(order_ts, 12, 2)
ORDER BY order_date, hour_text;

-- 7. CTE + CASE: % within SLA by cluster, flagged
WITH cluster_sla AS (
    SELECT
        ds.cluster,
        AVG(o.within_sla) AS pct_sla,
        COUNT(*) AS n_orders
    FROM orders AS o
    JOIN dark_stores AS ds ON o.store_id = ds.store_id
    WHERE o.status = 'Delivered'
    GROUP BY ds.cluster
)
SELECT
    cluster,
    ROUND(pct_sla * 100, 1) AS pct_sla,
    n_orders,
    CASE WHEN pct_sla < 0.85 THEN 'NEEDS ATTENTION' ELSE 'OK' END AS flag
FROM cluster_sla
ORDER BY pct_sla ASC;
