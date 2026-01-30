# 🍜 Danny's Diner – SQL Case Study

![Danny's Diner](images/dannys_diner.png)

## 📌 Project Overview
This project contains SQL solutions for the Danny's Diner case study, focused on analyzing customer behavior, sales performance, and loyalty program impact.
The goal of the analysis is to answer business questions related to:
- customer visits and spending,
- product popularity,
- membership program performance,
- loyalty points calculations.

All queries were written in SQL using joins, aggregations, CTEs, and window functions.

## 🗃️ Dataset Description
The case study uses three tables:
- sales – customer orders with order dates and product IDs
- menu – product details and prices
- members – customers who joined the loyalty program and their join dates

## 🛠 SQL Concepts Used
The project demonstrates practical usage of:
- JOIN operations
- Aggregations (SUM, COUNT)
- CASE expressions
- Common Table Expressions (CTE)
- Window functions (ROW_NUMBER, RANK)
- Filtering and grouping techniques (WHERE, GROUP BY)

## 📊 Business Questions Answered
Examples of analysis performed:
- Total amount spent by each customer
- Number of days each customer visited the restaurant
- First item purchased by each customer
- Most purchased item overall
- Most popular item per customer
- Purchases before and after membership
- Loyalty points calculations
- Bonus analysis with ranking of member purchases

All SQL queries are available in the repository files.

## 📁 Repository Structure
```
dannys-diner-sql/
├── database/   # database schema and raw data
├── images/     # images used in documentation
├── queries/    # SQL solution files
└── README.md   # project documentation
```
## 📈 Queries & Results

### 🧾 Question 1
What is the total amount each customer spent at the restaurant?
#### 💻 SQL Query
``` sql
SELECT 
	s.customer_id, 
	TO_CHAR(SUM(m.price),'FM$9999.00') AS total_amount
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m 
	ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount DESC;
```
#### 📊 Result
| customer_id | total_amount |
|------------|-------------:|
| A          | $76.00      |
| B          | $74.00      |
| C          | $36.00      |

### 🧾 Question 2
How many days has each customer visited the restaurant?
#### 💻 SQL Query
``` sql
SELECT 
	customer_id, 
	COUNT(distinct order_date) AS visiting_days
FROM dannys_diner.sales
GROUP BY customer_id;
```
#### 📊 Result
| customer_id | visiting_days |
|------------|--------------:|
| A          | 4            |
| B          | 6            |
| C          | 2            |

### 🧾 Question 3
What was the first item from the menu purchased by each customer?
#### 💻 SQL Query
``` sql
-- Using CTE and Window function ROW_NUMBER()
WITH first_order AS (
	SELECT
		s.customer_id, 
		s.order_date, 
		s.product_id,
		ROW_NUMBER() OVER (
			PARTITION BY s.customer_id 
			ORDER BY s.order_date ASC) AS rn
	FROM dannys_diner.sales AS s
)

SELECT 
	fo.customer_id,
	fo.order_date,
	m.product_name
FROM first_order AS fo
INNER JOIN dannys_diner.menu AS m 
	ON fo.product_id = m.product_id
WHERE fo.rn = 1
ORDER BY fo.customer_id;
```
#### 📊 Result
| customer_id | order_date  | product_name |
|------------|------------|--------------|
| A          | 2021-01-01 | sushi        |
| B          | 2021-01-01 | curry        |
| C          | 2021-01-01 | ramen        |

### 🧾 Question 4
What is the most purchased item on the menu and how many times was it purchased by all customers?
#### 💻 SQL Query
##### 🔹 1st version of the solution 
``` sql
-- Using LIMIT clause
-- Returns a single most purchased item
-- If multiple items share the same highest count, only one is returned

SELECT m.product_name,
	COUNT(*) AS number_of_orders
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY number_of_orders DESC
LIMIT 1;
```
##### 🔹 2nd version of the solution 
``` sql
-- Using CTE and window function RANK()
-- Returns all items tied for the highest number of purchases

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
```
#### 📊 Result
| product_name | number_of_orders |
|-------------|----------------:|
| ramen       | 8               |

### 🧾 Question 5
Which item was the most popular for each customer?
#### 💻 SQL Query
``` sql
-- Uses RANK() to correctly handle ties in purchase counts

WITH popular_orders AS (
	SELECT 
		s.customer_id,
		s.product_id,
		COUNT(*) AS item_count
	FROM dannys_diner.sales AS s
	GROUP BY s.customer_id, s.product_id
),

ranked_orders AS (
	SELECT 
		po.customer_id, 
		po.product_id,
		po.item_count,
		RANK() OVER (
			PARTITION BY po.customer_id 
			ORDER BY po.item_count DESC) AS rnk 
	FROM popular_orders AS po
)

SELECT 
	ro.customer_id,
	m.product_name,
	ro.item_count
FROM ranked_orders AS ro
INNER JOIN dannys_diner.menu AS m 
	ON ro.product_id = m.product_id
WHERE ro.rnk = 1;
```
#### 📊 Result
| customer_id | product_name | item_count |
|------------|-------------|-----------:|
| A          | ramen       | 3         |
| B          | ramen       | 2         |
| B          | sushi       | 2         |
| B          | curry       | 2         |
| C          | ramen       | 3         |

### 🧾 Question 6
Which item was purchased first by the customer after they became a member?
#### 💻 SQL Query
``` sql
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
```
#### 📊 Result
| customer_id | order_date  | product_id | product_name |
|------------|------------|-----------:|-------------|
| A          | 2021-01-10 | 3          | ramen       |
| B          | 2021-01-11 | 1          | sushi       |

### 🧾 Question 7
Which item was purchased just before the customer became a member?
#### 💻 SQL Query
``` sql
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
```
#### 📊 Result
| customer_id | order_date  | product_id | product_name |
|------------|------------|-----------:|-------------|
| A          | 2021-01-01 | 1          | sushi       |
| B          | 2021-01-04 | 1          | sushi       |

### 🧾 Question 8
What is the total items and amount spent for each member before they became a member?
#### 💻 SQL Query
``` sql
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
```
#### 📊 Result
| customer_id | total_items | amount_spent |
|------------|------------:|------------:|
| A          | 2           | 25          |
| B          | 3           | 40          |

### 🧾 Question 9
If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
#### 💻 SQL Query
``` sql

SELECT 
	s.customer_id,
	SUM(CASE
			WHEN m.product_name = 'sushi'
				THEN m.price * 10 * 2
			ELSE m.price * 10
		END
	) AS total_points
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m 
	ON m.product_id = s.product_id
GROUP BY customer_id
ORDER BY customer_id;
```
#### 📊 Result
| customer_id | total_points |
|------------|-------------:|
| A          | 860          |
| B          | 940          |
| C          | 360          |

### 🧾 Question 10
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
#### 💻 SQL Query
``` sql
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
```
#### 📊 Result
| customer_id | total_points |
|------------|-------------:|
| A          | 1370         |
| B          | 820          |

## ⭐ Bonus Questions

### 🧾 Join All The Things
- Recreate a consolidated sales table by joining sales, menu, and members data
- Add a member flag (Y/N) to indicate whether each order was placed after the customer joined the loyalty program
#### 💻 SQL Query
``` sql
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
```
#### 📊 Result
| customer_id | order_date  | product_name | price | member |
|------------|------------|-------------|------:|:-------|
| A          | 2021-01-01 | sushi       | 10    | N      |
| A          | 2021-01-01 | curry       | 15    | N      |
| A          | 2021-01-07 | curry       | 15    | Y      |
| A          | 2021-01-10 | ramen       | 12    | Y      |
| A          | 2021-01-11 | ramen       | 12    | Y      |
| A          | 2021-01-11 | ramen       | 12    | Y      |
| B          | 2021-01-01 | curry       | 15    | N      |
| B          | 2021-01-02 | curry       | 15    | N      |
| B          | 2021-01-04 | sushi       | 10    | N      |
| B          | 2021-01-11 | sushi       | 10    | Y      |
| B          | 2021-01-16 | ramen       | 12    | Y      |
| B          | 2021-02-01 | ramen       | 12    | Y      |
| C          | 2021-01-01 | ramen       | 12    | N      |
| C          | 2021-01-01 | ramen       | 12    | N      |
| C          | 2021-01-07 | ramen       | 12    | N      |

### 🧾 Rank All The Things
- Rank customer purchases made after joining the loyalty program
- Only member orders receive a ranking; non-member orders remain NULL
#### 💻 SQL Query
``` sql
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
```
#### 📊 Result
| customer_id | order_date  | product_name | price | member | ranking |
|------------|------------|-------------|------:|:-------|--------:|
| A          | 2021-01-01 | curry       | 15    | N      |         |
| A          | 2021-01-01 | sushi       | 10    | N      |         |
| A          | 2021-01-07 | curry       | 15    | Y      | 1       |
| A          | 2021-01-10 | ramen       | 12    | Y      | 2       |
| A          | 2021-01-11 | ramen       | 12    | Y      | 3       |
| A          | 2021-01-11 | ramen       | 12    | Y      | 3       |
| B          | 2021-01-01 | curry       | 15    | N      |         |
| B          | 2021-01-02 | curry       | 15    | N      |         |
| B          | 2021-01-04 | sushi       | 10    | N      |         |
| B          | 2021-01-11 | sushi       | 10    | Y      | 1       |
| B          | 2021-01-16 | ramen       | 12    | Y      | 2       |
| B          | 2021-02-01 | ramen       | 12    | Y      | 3       |
| C          | 2021-01-01 | ramen       | 12    | N      |         |
| C          | 2021-01-01 | ramen       | 12    | N      |         |
| C          | 2021-01-07 | ramen       | 12    | N      |         |
