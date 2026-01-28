-- The most purchased item on the menu and the number of times it was purchased by all customers.
-- Using CTE and window function RANK()
-- Returns all items tied for the highest number of purchases.

WITH ordered_items AS (
	SELECT m.product_name,
		COUNT(*) AS number_of_orders,
		RANK() OVER (
		ORDER BY COUNT(*) DESC) AS rnk
	FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
	GROUP BY m.product_name
)

SELECT o.product_name, o.number_of_orders
FROM ordered_items AS o
WHERE o.rnk = 1;