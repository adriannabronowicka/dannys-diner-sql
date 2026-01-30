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
├── database/   # database schema or raw data
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
##### 1st version of the solution 
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
##### 2nd version of the solution 
``` sql
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
```
#### 📊 Result
| product_name | number_of_orders |
|-------------|----------------:|
| ramen       | 8               |
