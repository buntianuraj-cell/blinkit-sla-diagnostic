-- verify.sql - Quick sanity checks

-- 1. Tables exist?
SELECT 'dark_stores' AS table_name, COUNT(*) AS rows FROM dark_stores
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'store_daily_metrics', COUNT(*) FROM store_daily_metrics;

-- 2. SLA columns exist and have values?
SELECT 
  COUNT(*) AS total_orders,
  SUM(CASE WHEN sla_minutes IS NOT NULL THEN 1 ELSE 0 END) AS with_sla,
  SUM(CASE WHEN met_sla IS NOT NULL THEN 1 ELSE 0 END) AS with_met_sla
FROM orders;

-- 3. Overall SLA breach rate should be between 0 and 1
SELECT 
  ROUND(1.0 * SUM(CASE WHEN met_sla = 0 THEN 1 ELSE 0 END) / COUNT(*), 4) AS breach_rate
FROM orders
WHERE met_sla IS NOT NULL;

-- 4. No duplicate order_id?
SELECT COUNT(*) AS total, COUNT(DISTINCT order_id) AS distinct_ids FROM orders;

-- 5. Check for bad dates
SELECT COUNT(*) AS bad_dates FROM orders WHERE order_date IS NULL;
