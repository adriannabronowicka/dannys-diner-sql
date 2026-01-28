-- The most popular item for each customer
-- Uses RANK() to correctly handle ties in purchase counts

WITH popular_orders AS (
	SELECT 
		s.customer_id,
		s.product_id,
		COUNT(*) AS item_count
	FROM dannys_diner.sales AS s
	GROUP BY s.customer_id, s.product_id
),

ranked_orders AS (
	SELECT 
		po.customer_id, 
		po.product_id,
		po.item_count,
		RANK() OVER (
			PARTITION BY po.customer_id 
			ORDER BY po.item_count DESC) AS rnk 
	FROM popular_orders AS po
)

SELECT 
	ro.customer_id,
	m.product_name,
	ro.item_count
FROM ranked_orders AS ro
INNER JOIN dannys_diner.menu AS m 
	ON ro.product_id = m.product_id
WHERE ro.rnk = 1;