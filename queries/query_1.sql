--Total amount each customer spent

SELECT 
	s.customer_id, 
	TO_CHAR(SUM(m.price),'FM$9999.00') AS total_amount
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m 
	ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount DESC;