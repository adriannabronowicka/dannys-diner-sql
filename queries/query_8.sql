-- The total items and amount spent for each member before they became a member

WITH orders_before_membership AS (
	SELECT 
		mb.customer_id, 
		mb.join_date, 
		s.order_date, 
		s.product_id,
		m.product_name, 
		m.price 
	FROM dannys_diner.members AS mb
	INNER JOIN dannys_diner.sales AS s 
		ON s.customer_id = mb.customer_id
	INNER JOIN dannys_diner.menu AS m 
		ON m.product_id = s.product_id
	WHERE s.order_date < mb.join_date  
)
SELECT 
	obm.customer_id, 
	COUNT(*) AS total_items, 
	SUM(obm.price) AS amount_spent
FROM orders_before_membership AS obm
GROUP BY obm.customer_id 
ORDER BY obm.customer_id;