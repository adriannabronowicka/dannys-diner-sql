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
