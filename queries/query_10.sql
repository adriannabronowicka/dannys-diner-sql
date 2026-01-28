-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
-- The number of points collected by customers A and B at the end of January

SELECT 
	mb.customer_id,
	SUM(CASE
			WHEN  s.order_date >= mb.join_date AND s.order_date < mb.join_date + INTERVAL '7 days'
				THEN m.price * 10 * 2
			WHEN m.product_name = 'sushi' 
				THEN m.price * 10 * 2
			ELSE m.price * 10 
		END 
	) AS total_points
FROM dannys_diner.members AS mb
INNER JOIN dannys_diner.sales AS s 
	ON s.customer_id = mb.customer_id
INNER JOIN dannys_diner.menu AS m 
	ON m.product_id = s.product_id
WHERE order_date <= '2021-01-31'
GROUP BY mb.customer_id
ORDER BY mb.customer_id;