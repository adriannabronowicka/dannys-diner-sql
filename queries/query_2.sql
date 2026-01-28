-- Number of days each customer has visited the restaurant

SELECT 
	customer_id, 
	COUNT(distinct order_date) AS visiting_days
FROM dannys_diner.sales
GROUP BY customer_id;
