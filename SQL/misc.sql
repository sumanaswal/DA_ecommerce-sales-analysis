-- 1. Row count per table
CREATE TEMP TABLE table_counts (
    table_name TEXT,
    row_count BIGINT
);

DO $$
DECLARE
    r RECORD;
    cnt BIGINT;
BEGIN
    FOR r IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw_olist'
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM raw_olist.%I',
            r.table_name
        )
        INTO cnt;

        INSERT INTO table_counts
        VALUES (r.table_name, cnt);
    END LOOP;
END $$;

SELECT *
FROM table_counts
ORDER BY table_name;

-- 2. check missing values in key tables
SELECT
	COUNT(*) AS total_orders,
	COUNT(order_delivered_customer_date) AS delivered,
	COUNT(order_approved_at) AS approved,
	SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery
FROM raw_olist.orders;

-- 3. converting date columns to Date data type
ALTER TABLE raw_olist.orders
ALTER COLUMN order_purchase_timestamp
TYPE TIMESTAMP
USING order_purchase_timestamp::TIMESTAMP;

ALTER TABLE raw_olist.orders
ALTER COLUMN order_approved_at
TYPE TIMESTAMP
USING order_approved_at::TIMESTAMP;

ALTER TABLE raw_olist.orders
ALTER COLUMN order_delivered_carrier_date
TYPE TIMESTAMP
USING order_delivered_carrier_date::TIMESTAMP;

ALTER TABLE raw_olist.orders
ALTER COLUMN order_delivered_customer_date
TYPE TIMESTAMP
USING order_delivered_customer_date::TIMESTAMP;

ALTER TABLE raw_olist.orders
ALTER COLUMN order_estimated_delivery_date
TYPE TIMESTAMP
USING order_estimated_delivery_date::TIMESTAMP;

-- to check invalid values in date column
SELECT order_purchase_timestamp
FROM raw_olist.orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_purchase_timestamp !~ '^\d{4}-\d{2}-\d{2}';

select  
	order_purchase_timestamp,
	DATE(order_purchase_timestamp)
from raw_olist.orders


