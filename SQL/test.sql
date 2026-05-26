WITH rfm_base AS (
    SELECT 
        customer_id,
        MAX(order_date) AS recency_date,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(item_total) AS monetary,
        CURRENT_DATE - MAX(order_date)::date AS recency_days
    FROM cleaned.fact_order_items
    GROUP BY customer_id
),
rfm_score AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,      -- Higher = better (more recent)
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_base
)
SELECT 
    *,
    (r_score + f_score + m_score) AS rfm_score,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customer'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk'
        WHEN r_score <= 2 THEN 'Lost Customer'
        ELSE 'Potential Loyalist'
    END AS customer_segment
FROM rfm_score;