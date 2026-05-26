import pandas as pd
from sqlalchemy import create_engine
import os
from pathlib import Path

# ====================== Configuration ========================
DB_USER = "postgres"
DB_PASSWORD = "root"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "olist_db"

DATA_FOLDER = Path("../data")       #adjust path if needed

# Connection
engine = create_engine(f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}')

# List of files (exact names from Olist dataset)
files = [
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv"
]

print("Starting data load...\n")

for file in files:
    table_name = file.replace("olist_","").replace("_dataset.csv","").replace(".csv","")
    file_path = DATA_FOLDER / file

    if not file_path.exists():
        print(f"file not found: {file}")
        continue

    print(f"loading {file} -> raw_olist.{table_name}")

    df = pd.read_csv(file_path)

    # load to raw schema
    df.to_sql(
        name=table_name,
        schema='raw_olist',
        con=engine,
        if_exists='replace',    # if table exists then delete it and replace it.
        index=False,            # excludes the pandas dataframe default index
        chunksize=10000         # sending data into chunks of 10k rows to prevent memory overload
    )

    #quick info
    print(f"Loaded {len(df):,} rows | Columns: {len(df.columns)}")

print("\n All tables loaded successfully into raw_olist schema!")

