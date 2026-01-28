-- Recreate a consolidated sales table by joining sales, menu, and members data
-- Add a member flag (Y/N) to indicate whether each order was placed after the customer joined the loyalty program

SELECT 
	s.customer_id, 
	s.order_date, 
	m.product_name, 
	m.price,
	CASE
		WHEN s.order_date >= mb.join_date 
			THEN 'Y'	-- Flag as member if order after join date
		ELSE 'N'		-- Otherwise flag as non-member
	END AS member
FROM dannys_diner.sales AS S 
INNER JOIN dannys_diner.menu AS m 
	ON m.product_id = s.product_id
LEFT JOIN dannys_diner.members AS mb 
	ON mb.customer_id = s.customer_id;
