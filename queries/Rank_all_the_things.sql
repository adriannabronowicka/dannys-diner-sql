-- Rank customer purchases made after joining the loyalty program
-- Only member orders receive a ranking; non-member orders remain NULL

-- Create a temporary table with all sales including member status
-- Flag orders as 'Y' if after joining the loyalty program, 'N' otherwise
WITH temporary_table AS (
    SELECT 
		s.customer_id, 
		s.order_date, 
		m.product_name, 
		m.price,
		CASE
		 -- Determine if the order was made after membership started
			WHEN s.order_date >= mb.join_date 
				THEN 'Y'
			ELSE 'N'
		END AS member
		FROM dannys_diner.sales AS S 
		INNER JOIN dannys_diner.menu AS m 
			ON m.product_id = s.product_id
		LEFT JOIN dannys_diner.members AS mb 
			ON mb.customer_id = s.customer_id
),
-- Remove duplicate member orders to eliminate repeated rows,
-- because sales do not have a unique order ID
-- Filter only orders after joining the loyalty program to ensure ranking starts at 1
member_orders AS (
	SELECT DISTINCT
		customer_id, 
		order_date, 
		product_name, 
		price,
		member,
		-- Rank member orders by order_date per customer
		RANK() OVER (
			PARTITION BY customer_id
			ORDER BY order_date) AS ranking
	FROM temporary_table 
	WHERE member = 'Y'
)

-- Combine all orders with the computed ranking for member orders
-- Non-member orders will show NULL in the ranking column
SELECT 
		t.customer_id, 
		t.order_date, 
		t.product_name, 
		t.price,
		t.member, 
		mo.ranking
FROM temporary_table AS t
LEFT JOIN member_orders AS mo
	ON mo.customer_id = t.customer_id
	AND mo.order_date = t.order_date
	AND mo.product_name = t.product_name
ORDER BY t.customer_id, t.order_date;
