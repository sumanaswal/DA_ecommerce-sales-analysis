-- =============================================
-- CLEANED DIMENSION TABLES
-- =============================================

-- 1. Dim Customers
CREATE TABLE cleaned.dim_customers AS
SELECT
	customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM raw_olist.customers;

-- 2. Dim Products with english category
CREATE TABLE cleaned.dim_products AS
SELECT
	p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM raw_olist.products p
LEFT JOIN raw_olist.product_category_name_translation t
	ON p.product_category_name = t.product_category_name;

-- 3. Dim Sellers
CREATE TABLE cleaned.dim_sellers AS
SELECT 
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw_olist.sellers;

-- 4. Dim Date (Very Important for Time Intelligence)
CREATE TABLE cleaned.dim_date AS
SELECT DISTINCT
    DATE(order_purchase_timestamp) AS date_key,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    TO_CHAR(order_purchase_timestamp, 'Month') AS month_name,
    EXTRACT(QUARTER FROM order_purchase_timestamp) AS quarter,
    EXTRACT(DOW FROM order_purchase_timestamp) AS day_of_week,
    TO_CHAR(order_purchase_timestamp, 'Day') AS day_name,
    CASE WHEN EXTRACT(DOW FROM order_purchase_timestamp) IN (0,6) THEN 'Weekend' ELSE 'Weekday' END AS weekend_flag -- 0 (Sunday) and 6 (Saturday) → 'Weekend'
FROM raw_olist.orders
WHERE order_purchase_timestamp IS NOT NULL;

-- 5. Fact Table - Order Items
DROP TABLE IF EXISTS cleaned.fact_order_items;
CREATE TABLE cleaned.fact_order_items AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
	c.customer_unique_id,
    oi.product_id,
    oi.seller_id,
    o.order_purchase_timestamp::date AS order_date,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    
    -- Measures
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS item_total,
    
    -- Derived flags & metrics
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_late_delivery,
    
    EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) AS delivery_delay_days,
    
    r.review_score,
    
    -- Payment (we'll handle multiple payments later)
    op.payment_type,
    op.payment_value

FROM raw_olist.order_items oi
JOIN raw_olist.orders o 
    ON oi.order_id = o.order_id
JOIN raw_olist.customers c
	ON c.customer_id = o.customer_id
LEFT JOIN raw_olist.order_reviews r 
    ON oi.order_id = r.order_id
LEFT JOIN raw_olist.order_payments op 
    ON oi.order_id = op.order_id;

-- Analytics Views

DROP VIEW IF EXISTS analytics.vw_sales_summary;

CREATE OR REPLACE VIEW analytics.vw_sales_summary AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(item_total)::NUMERIC,2) AS total_revenue,
    ROUND((SUM(item_total) / COUNT(DISTINCT order_id))::NUMERIC,2) AS avg_order_value,
    ROUND(AVG(review_score)::NUMERIC,2) AS avg_review_score,
    ROUND(
		(COUNT(
			DISTINCT CASE WHEN is_late_delivery = 1 THEN order_id END) * 100.0
			/ NULLIF(COUNT(DISTINCT order_id),0))::NUMERIC,2) AS late_delivery_pct
FROM cleaned.fact_order_items
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- RFM Analysis View
DROP VIEW IF EXISTS analytics.vw_rfm;

CREATE OR REPLACE VIEW analytics.vw_rfm AS
WITH customer_metrics AS (
    SELECT 
        customer_unique_id,
        MAX(order_date) AS last_purchase_date,
		DATE('2018-09-30') - MAX(order_date) as recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(item_total) AS monetary
    FROM cleaned.fact_order_items
    GROUP BY customer_unique_id
),
RFM_Scoring AS (
	SELECT
    	customer_unique_id,
    	last_purchase_date,
		recency_days,
    	frequency,
    	monetary,
    	NTILE(5) OVER (ORDER BY last_purchase_date) AS r_score,   -- Lower = more recent
    	NTILE(5) OVER (ORDER BY frequency) AS f_score,
    	NTILE(5) OVER (ORDER BY monetary) AS m_score
FROM customer_metrics
)
SELECT
	customer_unique_id,
	last_purchase_date,
	recency_days,
	frequency,
	monetary,
	CONCAT(r_score,f_score,m_score) AS rfm_score,

	-- using CASE to group scores into meaningful marketing sagments
	CASE
		WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions (VIP)'
		WHEN r_score >= 4 AND f_score >= 4 THEN 'Recent Customers (Nurture)'
		WHEN r_score < 4 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk (High Value)'
		WHEN r_score < 3 AND f_score < 3 THEN 'Lost/Churned Customers'
		ELSE 'Average Core Customers'
	END AS customer_segment
FROM RFM_Scoring
ORDER BY rfm_score DESC