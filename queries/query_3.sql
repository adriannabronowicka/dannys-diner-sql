-- The first item from the menu purchased by each customer
-- Using CTE and Window function ROW_NUMBER()

WITH first_order AS (
	SELECT
		s.customer_id, 
		s.order_date, 
		s.product_id,
		ROW_NUMBER() OVER (
			PARTITION BY s.customer_id 
			ORDER BY s.order_date ASC) AS rn
	FROM dannys_diner.sales AS s
)

SELECT 
	fo.customer_id,
	fo.order_date,
	m.product_name
FROM first_order AS fo
INNER JOIN dannys_diner.menu AS m 
	ON fo.product_id = m.product_id
WHERE fo.rn = 1
ORDER BY fo.customer_id;