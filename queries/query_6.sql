-- First item purchased by the customer after they became a member

WITH member_orders AS (
	SELECT 
		mb.customer_id,
		mb.join_date,
		s.order_date,
		s.product_id,
		ROW_NUMBER() OVER (
			PARTITION BY mb.customer_id 
			ORDER BY order_date) AS rn
	FROM dannys_diner.members AS mb
	INNER JOIN dannys_diner.sales AS s 
		ON s.customer_id = mb.customer_id
	WHERE s.order_date > mb.join_date
)

SELECT 
	mo.customer_id,
	mo.order_date,
	m.product_id,
	m.product_name
FROM member_orders AS mo
INNER JOIN dannys_diner.menu AS m 
	ON mo.product_id = m.product_id
WHERE rn = 1;