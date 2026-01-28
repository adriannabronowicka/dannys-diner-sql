-- The most purchased item on the menu and the number of times it was purchased by all customers.
-- Using LIMIT clause
-- Returns a single most purchased item
-- If multiple items share the same highest count, only one is returned

SELECT m.product_name,
	COUNT(*) AS number_of_orders
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY number_of_orders DESC
LIMIT 1
;


