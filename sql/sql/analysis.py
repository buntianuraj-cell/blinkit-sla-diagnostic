import sqlite3, pandas as pd

con = sqlite3.connect("data/blinkit.db")

# 1. Overall SLA
q1 = pd.read_sql("SELECT AVG(within_sla)*100 AS pct_sla, COUNT(*) AS n FROM orders WHERE status='Delivered'", con)
print("Overall SLA %:")
print(q1)

# 2. SLA by Cluster - THE KEY FINDING
q2 = pd.read_sql("""
SELECT ds.cluster, COUNT(*) AS n, ROUND(AVG(o.within_sla)*100,1) AS pct_sla,
ROUND(AVG(o.delivery_minutes),2) AS avg_mins
FROM orders o JOIN dark_stores ds ON o.store_id=ds.store_id
WHERE o.status='Delivered' GROUP BY ds.cluster ORDER BY pct_sla ASC
""", con)
print("\nSLA by Cluster (worst first):")
print(q2)

# 3. SLA by Category
q3 = pd.read_sql("""
SELECT category, COUNT(*) AS n, ROUND(AVG(within_sla)*100,1) AS pct_sla,
ROUND(AVG(delivery_minutes),2) AS avg_mins
FROM orders WHERE status='Delivered' GROUP BY category ORDER BY pct_sla ASC
""", con)
print("\nSLA by Category:")
print(q3)

# 4. SLA by Hour Band
q4 = pd.read_sql("""
SELECT hb.band, COUNT(*) AS n, ROUND(AVG(o.within_sla)*100,1) AS pct_sla
FROM orders o JOIN hour_bands hb ON hb.hour_text=SUBSTR(o.order_ts,12,2)
WHERE o.status='Delivered' GROUP BY hb.band
""", con)
print("\nSLA by Hour Band:")
print(q4)

# 5. SLA by Store
q5 = pd.read_sql("""
SELECT ds.store_name, ds.cluster, COUNT(*) AS n, ROUND(AVG(o.within_sla)*100,1) AS pct_sla
FROM orders o JOIN dark_stores ds ON o.store_id=ds.store_id
WHERE o.status='Delivered' GROUP BY ds.store_id ORDER BY pct_sla ASC
""", con)
print("\nSLA by Store:")
print(q5)

# Save for README
q2.to_csv("data/sla_by_cluster.csv", index=False)
q3.to_csv("data/sla_by_category.csv", index=False)
q4.to_csv("data/sla_by_hour.csv", index=False)
print("\nSaved CSVs to data/")
