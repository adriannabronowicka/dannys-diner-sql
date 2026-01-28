-- The item was purchased just before the customer became a member

WITH no_member_orders AS (
	SELECT 
		mb.customer_id, 
		mb.join_date,
		s.order_date,
		s.product_id,
		ROW_NUMBER() OVER (
			PARTITION BY mb.customer_id 
			ORDER BY order_date DESC) AS rn
		FROM dannys_diner.members AS mb
		INNER JOIN dannys_diner.sales AS s 
			ON s.customer_id = mb.customer_id
		WHERE s.order_date < mb.join_date
)

SELECT 
	nmo.customer_id,
	nmo.order_date,
	m.product_id,
	m.product_name
FROM no_member_orders AS nmo
INNER JOIN dannys_diner.menu AS m 
	ON nmo.product_id = m.product_id
WHERE rn = 1;