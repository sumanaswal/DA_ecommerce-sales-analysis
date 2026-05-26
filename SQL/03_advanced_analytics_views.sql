-- =============================================
-- ADVANCED ANALYTICS VIEWS
-- =============================================

-- 1. Seller Performance View
CREATE OR REPLACE VIEW analytics.vw_seller_performance as
WITH order_level_summary AS (
	-- Step 1: Collapse many items into one unique order row
	SELECT
		seller_id,
		order_id,
		SUM(item_total) AS order_total_revenue,
		MAX(review_score) AS order_review_score,
		MAX(delivery_delay_days) AS order_delivery_delay,
		MAX(is_late_delivery) AS order_late_delivery
	FROM cleaned.fact_order_items
	GROUP BY order_id, seller_id
)
-- Step 2: Aggregate by Seller
SELECT
	s.seller_id,
	s.seller_state,
	COUNT(o.order_id) AS total_orders,
	ROUND(SUM(o.order_total_revenue)::NUMERIC,2) AS total_revenue,
	ROUND(AVG(o.order_total_revenue)::NUMERIC,2) AS avg_order_value,
	ROUND(AVG(o.order_review_score),2) AS avg_review_score,
	ROUND(AVG(o.order_delivery_delay),2) AS avg_delivery_delay,
	ROUND(SUM(o.order_late_delivery) * 100.0 / COUNT(*),2) AS late_delivery_pct,
	COUNT(CASE WHEN o.order_review_score >= 4 THEN o.order_id END) AS high_rated_orders
FROM order_level_summary o
JOIN cleaned.dim_sellers s
	ON o.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY total_revenue DESC
-- =============================================

-- 2. Category Performance View
CREATE OR REPLACE VIEW analytics.vw_category_performance AS
WITH order_level AS (
	-- Aggregate at order level first to avoid duplication on reviews
	SELECT
		product_id,
		order_id,
		customer_id,
		SUM(item_total) AS order_revenue,
		MAX(price) as price,
		MAX(review_score) AS review_score
	FROM cleaned.fact_order_items
	GROUP BY product_id, order_id,customer_id
)

SELECT
	p.product_category_name_english AS category,
	COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(o.order_revenue) AS total_revenue,
	AVG(o.price) AS avg_item_price,
	AVG(o.review_score) as avg_rating,
	COUNT(DISTINCT o.customer_id) AS unique_customers,
	SUM(o.order_revenue) / COUNT(DISTINCT o.order_id) AS avg_order_value_from_category,
	COUNT(o.product_id) AS total_items_sold
FROM order_level o
JOIN cleaned.dim_products p
	ON o.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY total_revenue DESC;
-- =============================================

-- 3. Customer RFM + Segmentation (Very Important)
--CREAET OR REPLACE VIEW analytics.vw.customer_rfm_segment AS
WITH rfm_base AS (
	SELECT
		customer_unique_id,
		MAX(order_date) AS recency_date,
		COUNT(DISTINCT order_id) AS frequency,
		SUM(item_total) AS monetary,
		DATE(NOW()) - MAX(order_date) AS recency_days
	FROM cleaned.fact_order_items
	GROUP BY customer_unique_id
),
customer_rfm_score AS (
	-- scoring customer 
	SELECT
		customer_unique_id,
		recency_date,
		frequency,
		monetary,
		recency_days,
		NTILE(5) OVER(ORDER BY recency_date ) AS r_score,
		NTILE(5) OVER(ORDER BY frequency ) AS f_score,
		NTILE(5) OVER(ORDER BY monetary) AS m_score
	FROM rfm_base
)
SELECT
	customer_unique_id,
	recency_date,
	frequency,
	monetary,
	recency_days,
	r_score,
	f_score,
	m_score,
	(r_score + f_score + m_score) AS rfm_score,
	CASE
		WHEN f_score >= 4 AND m_score >=4 THEN 'Champion'
		WHEN f_score >= 3 THEN 'Loyal Customer'
		WHEN r_score >= 4 THEN 'New Customer'
		WHEN r_score <= 2 THEN 'At Risk'
		ELSE 'One-Time Buyer'
		END AS customer_segment
FROM customer_rfm_score;

-- 4. Geography View (State Level)	customer state, total order, total revenue, late delivery pct, avg review
SELECT
	c.customer_state,
	o.order_id,
	SUM(o.item_total) as order_revenue,
	MAX(is_late_delivery) is_l
FROM cleaned.fact_order_items o
JOIN cleaned.dim_customers c
	ON c.customer_id = o.customer_id
GROUP BY c.customer_state, o.order_id;


select
	count(*) tota
from cleaned.fact_order_items WHERE delivery_delay_days > 0;



	