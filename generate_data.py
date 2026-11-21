import random, sqlite3, os
from datetime import datetime, timedelta

random.seed(42)
os.makedirs("data", exist_ok=True)
DB = "data/blinkit.db"
if os.path.exists(DB):
    os.remove(DB)

con = sqlite3.connect(DB)
cur = con.cursor()

# Tables
cur.execute("CREATE TABLE dark_stores (store_id TEXT PRIMARY KEY, store_name TEXT, cluster TEXT, city TEXT, opened_date TEXT)")
cur.execute("CREATE TABLE hour_bands (hour_text TEXT PRIMARY KEY, band TEXT)")
cur.execute("""CREATE TABLE orders (
    order_id TEXT PRIMARY KEY, store_id TEXT, order_ts TEXT, category TEXT,
    status TEXT, delivery_minutes REAL, within_sla INTEGER,
    FOREIGN KEY(store_id) REFERENCES dark_stores(store_id))""")

# Hour bands
for h in range(24):
    ht = f"{h:02d}"
    if 6 <= h < 11: band = "Morning"
    elif 11 <= h < 16: band = "Midday"
    elif 16 <= h < 21: band = "Evening Peak"
    else: band = "Night"
    cur.execute("INSERT INTO hour_bands VALUES (?,?)", (ht, band))

# Stores - 13 total, 12 live, 1 not live
stores = [
    ("S01","Andheri West","Andheri","Mumbai","2023-01-10"),
    ("S02","Andheri East","Andheri","Mumbai","2023-02-15"),
    ("S03","Powai Main","Powai","Mumbai","2023-03-01"),
    ("S04","Powai Annex","Powai","Mumbai","2024-12-01"),
    ("S05","Thane West","Thane","Mumbai","2023-01-20"),
    ("S06","Thane East","Thane","Mumbai","2023-04-10"),
    ("S07","Bandra West","Bandra","Mumbai","2023-05-05"),
    ("S08","Bandra East","Bandra","Mumbai","2023-06-12"),
    ("S09","Borivali West","Borivali","Mumbai","2023-07-01"),
    ("S10","Borivali East","Borivali","Mumbai","2023-08-15"),
    ("S11","Malad West","Malad","Mumbai","2023-09-01"),
    ("S12","Malad East","Malad","Mumbai","2023-10-01"),
    ("S13","Goregaon West","Goregaon","Mumbai","2023-11-01"),
]
cur.executemany("INSERT INTO dark_stores VALUES (?,?,?,?,?)", stores)
live = [s for s in stores if s[0] != "S04"]

# Categories with different SLA behavior
cats = ["Grocery","Dairy","Snacks","Beverages","Fruits"]
base_mins = {"Grocery":14,"Dairy":11,"Snacks":13,"Beverages":12,"Fruits":15}
cluster_penalty = {"Andheri":2.5,"Powai":1.0,"Thane":3.5,"Bandra":0.5,"Borivali":2.0,"Malad":1.5,"Goregaon":1.0}

start = datetime(2024,1,1)
orders = []
for i in range(1,6001):
    store = random.choice(live)
    cluster = store[2]
    cat = random.choice(cats)
    # 6.4% cancelled = 384
    status = "Cancelled" if random.random() < 0.064 else "Delivered"
    # Random timestamp Jan-Mar 2024, peak hours more likely
    day = random.randint(0,89)
    hour = random.choices(range(24), weights=[1,1,1,1,1,1,3,5,6,5,4,5,6,5,4,5,7,8,7,5,3,2,1,1])[0]
    ts = start + timedelta(days=day, hours=hour, minutes=random.randint(0,59))
    if status == "Cancelled":
        dm, sla = None, None
    else:
        dm = max(4, round(random.gauss(base_mins[cat] + cluster_penalty[cluster], 4.5),1))
        sla = 1 if dm <= 15 else 0
    orders.append((f"O{i:05d}", store[0], ts.strftime("%Y-%m-%d %H:%M:%S"), cat, status, dm, sla))

cur.executemany("INSERT INTO orders VALUES (?,?,?,?,?,?,?)", orders)
con.commit()
print(f"Done: {len(orders)} orders, {len(stores)} stores")
print(cur.execute("SELECT status, COUNT(*) FROM orders GROUP BY status").fetchall())
print(cur.execute("SELECT COUNT(DISTINCT store_id) FROM orders").fetchall())
con.close()
