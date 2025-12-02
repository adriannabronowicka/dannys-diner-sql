-- Database tables created according to the Entity-Relationship Diagram provided in this Danny’s Diner case study.
-- Menu table containing all available products and their prices.

CREATE TABLE members
(customer_id VARCHAR(1) PRIMARY KEY,
join_date DATE);

-- Members table storing customers who joined the loyalty program.

CREATE TABLE menu
(product_id INTEGER PRIMARY KEY,
product_name VARCHAR(5),
price INTEGER);

--The table contains information about all customer purchases.
-- Duplicate records are allowed since customers can order the same item multiple times.
-- No foreign key on customer_id because customer C is not a loyalty member.

CREATE TABLE sales
(customer_id VARCHAR(1),
order_date DATE,
product_id INTEGER,
FOREIGN KEY (product_id) REFERENCES menu(product_id));
