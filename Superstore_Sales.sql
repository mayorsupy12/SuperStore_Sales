CREATE DATABASE Superstore_Sales;
use Superstore_Sales;

CREATE TABLE Customers(
customer_id  VARCHAR(50) primary key,  
 customer_name VARCHAR(50),
 segment VARCHAR(50));
 

CREATE TABLE Orders ( 
order_id VARCHAR(50) primary key,
 order_date VARCHAR(50),
 ship_date VARCHAR(50),
 customer_id VARCHAR (50),
 shipmode_id INT,
 postal_code INT,
 FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
 FOREIGN KEY (shipmode_id) REFERENCES Ship_Modes (shipmode_id),
 FOREIGN KEY (postal_code) REFERENCES Location(postal_code));


CREATE TABLE Products (    
product_id VARCHAR(250) primary key,
product_name VARCHAR(250),
Sub_Category_id INT,
FOREIGN KEY (Sub_Category_id) REFERENCES Sub_Categories(Sub_Category_id)
 );

CREATE TABLE Categories(
category_id INT primary key, 
 category_name VARCHAR(250));
 
CREATE TABLE Sub_Categories(
Sub_Category_id INT primary key, 
 subcategory_name TEXT,
 category_id INT,
 FOREIGN KEY (category_id) REFERENCES Categories(category_id)
 );
 

CREATE TABLE Location(  
postal_code INT primary key, 
 city VARCHAR(50),
 state VARCHAR(50),
 region VARCHAR (50),
 country VARCHAR (50));


CREATE TABLE Ship_Modes(                         
shipmode_id INT primary key,
 ship_mode VARCHAR (50));


CREATE TABLE Order_Details(
 row_id INT PRIMARY KEY,
 quantity INT ,
 sales DECIMAL,
 discount DOUBLE,
 profit DOUBLE,
 order_id VARCHAR (50),
 product_id VARCHAR (250),
 FOREIGN KEY (order_id) REFERENCES Orders(order_id),
 FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- DATA CLEANING
-- CHANGED ORDER AND SHIP DATE FORMAT . THEN CHANGED THE DATATYPE FROM VARCHAR TO DATE
select * from orders;
SET SQL_SAFE_UPDATES = 0;
UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%c/%e/%Y')
WHERE order_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

UPDATE orders
SET ship_date = STR_TO_DATE(ship_date, '%c/%e/%Y')
WHERE ship_date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

ALTER TABLE orders
MODIFY COLUMN order_date DATE;

ALTER TABLE orders
MODIFY COLUMN ship_date DATE;

SHOW COLUMNS FROM orders;


-- ANALYSIS  
-- 1. Top 5 customers by total sales 
SELECT c.customer_id, sum(od.sales) as total_sales 
from Customers as c
join Orders as o
on c.customer_id = c.customer_id
join Order_Details as od
on o.order_id = od.order_id
group by c.customer_id
ORDER BY total_sales DESC
limit 5;

-- 2. Total profit per region
select l.region, ROUND(sum(od.profit),0) as total_profit
from order_details as od 
join orders as o ON od.order_id = o.order_id
join location as l ON O.postal_code = l.postal_code
group by region;

-- 3. Most profitable sub-category
select subcategory_name, sum(od.profit) as total_profit
from order_details as od 
join Products as P  USING  (product_id)
join Sub_Categories as sc USING (Sub_Category_id)
group by subcategory_name
ORDER BY total_profit DESC
LIMIT 1;

-- 4. Year-over-year sales growth
WITH yearly_sales AS (
  SELECT
    EXTRACT(YEAR FROM o.order_date) AS sales_year,
    SUM(od.sales) AS total_sales
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY sales_year
)

SELECT
  sales_year,
  total_sales,
  LAG(total_sales) OVER (ORDER BY sales_year) AS previous_year_sales,
  ROUND(
    100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY sales_year)) /
    NULLIF(LAG(total_sales) OVER (ORDER BY sales_year), 0), 2
  ) AS year_over_year_growth_percentage
FROM yearly_sales
ORDER BY sales_year;

-- 5. Top 3 states with highest number of orders

SELECT l.state, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders as o
JOIN location as l ON o.postal_code = l.postal_code
GROUP BY l.state
ORDER BY total_orders DESC
LIMIT 3;

-- 6 Average delivery time per ship mode
SELECT sm.ship_mode, ROUND(AVG(o.ship_date - o.order_date), 2) AS avg_delivery_days
FROM orders as o
JOIN ship_modes as sm ON o.shipmode_id = sm.shipmode_id
GROUP BY sm.ship_mode
ORDER BY avg_delivery_days;

-- 7 Total sales per category
SELECT category_name, sum(sales) as total_sales
from order_details as od
join products as p USING (product_id)
JOIN sub_categories as sc USING (Sub_Category_id)
JOIN categories as c USING (category_id)
GROUP BY category_name;

-- 9 Most returned product (if return data is available or mocked)
-- (RETURN DATA NOT AVAILABLE)

-- 10. Customer segmentation by frequency of orders and sales volume

SELECT
  c.customer_id,
  c.customer_name,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(od.sales) AS total_sales,
  CASE
    WHEN COUNT(DISTINCT o.order_id) >= 10 AND SUM(od.sales) >= 5000 THEN 'High Value'
    WHEN COUNT(DISTINCT o.order_id) >= 5 AND SUM(od.sales) >= 2000 THEN 'Medium Value'
    ELSE 'Low Value'
  END AS customer_segment
FROM customers c
JOIN orders as o ON c.customer_id = o.customer_id
JOIN order_details as od ON o.order_id = od.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales DESC;

-- 11 The total sales, profit, and quantity sold across all orders
SELECT o.order_id, sum(sales) as total_sales, sum(profit) as total_profit, SUM(quantity) as total_quantity_sold
FROM order_details AS od
join orders as o USING (order_id)
group by o.order_id;

-- 12. Sales, profit, and quantity trends over time by quarter - so cool to see the seasonality!

SELECT
  EXTRACT(YEAR FROM o.order_date) AS year,
  EXTRACT(QUARTER FROM o.order_date) AS quarter,
  SUM(od.sales) AS total_sales,
  SUM(od.profit) AS total_profit,
  SUM(od.quantity) AS total_quantity
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY year, quarter
ORDER BY year, quarter;

-- 13. Identified the top sales quarter for each year

SELECT sales, 
EXTRACT(YEAR FROM o.order_date) AS year,
EXTRACT(QUARTER FROM o.order_date) AS quarter
FROM orders as o
join order_details as od USING (order_id)
GROUP BY sales
order by sales DESC;
WITH quarterly_sales AS (
  SELECT
    EXTRACT(YEAR FROM o.order_date) AS sales_year,
    EXTRACT(QUARTER FROM o.order_date) AS sales_quarter,
    SUM(od.sales) AS total_sales
  FROM orders as o
  JOIN order_details as od ON o.order_id = od.order_id
  GROUP BY sales_year, sales_quarter
),
ranked_quarters AS (
  SELECT *,
         RANK() OVER (PARTITION BY sales_year ORDER BY total_sales DESC) AS sales_rank
  FROM quarterly_sales
)
SELECT sales_year, sales_quarter, total_sales
FROM ranked_quarters
WHERE sales_rank = 1
ORDER BY sales_year;

-- 14. Top selling and most profitable product categories and sub-categories

SELECT
  c.category_name,sc.subcategory_name,
  SUM(od.sales) AS total_sales,
  round(SUM(profit),0) AS total_profit
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN sub_categories sc ON p.Sub_Category_id = sc.Sub_Category_id
JOIN categories c ON sc.category_id = c.category_id
GROUP BY c.category_name, sc.subcategory_name
ORDER BY total_sales DESC;

-- 15. Regional sales and profit breakdown

SELECT
  l.region,
  SUM(od.sales) AS total_sales,
  ROUND(SUM(profit),0) AS total_profit
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN location l ON o.postal_code = l.postal_code
GROUP BY l.region
ORDER BY total_sales DESC;

-- 16. Most valuable customer segments

SELECT c.segment,
  COUNT(DISTINCT o.customer_id) AS num_customers,
  SUM(od.sales) AS total_sales,
  SUM(profit) AS total_profit
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.segment
ORDER BY total_sales DESC;

-- 17. Top selling and profitable individual products
SELECT p.product_id, p.product_name  , sum(od.sales) as total_sales, sum(od.profit) as total_profit
FROM products as p
join order_details as od USING (product_id)
group by p.product_id, p.product_name
order by total_sales  DESC;

-- Impact of discounts on sales and profit

SELECT
  od.discount,
  COUNT(*) AS num_orders,
  SUM(od.sales) AS total_sales,
  SUM(od.profit) AS total_profit,
  ROUND(AVG(od.sales), 2) AS avg_sales_per_order,
  ROUND(AVG(od.profit), 2) AS avg_profit_per_order
FROM order_details od
GROUP BY od.discount
ORDER BY od.discount DESC;

-- 21. Top customers by total sales and profit
SELECT c.customer_id, c.customer_name, sum(od.sales) as total_sales, sum(od.profit) as total_profit
from customers as c
JOIN orders as o USING (customer_id)
JOIN order_details as od USING (order_id)
GROUP BY c.customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- 23. RFM analysis to identify best customers

WITH recency AS (
  SELECT
    customer_id,
    DATEDIFF(CURDATE(), MAX(order_date)) AS recency_days
  FROM orders
  GROUP BY customer_id
),
frequency AS (
  SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS frequency
  FROM orders
  GROUP BY customer_id
),
monetary AS (
  SELECT
    o.customer_id,
    SUM(od.sales) AS monetary
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY o.customer_id
)

SELECT
  r.customer_id,
  r.recency_days,
  f.frequency,
  m.monetary,
  CASE
    WHEN r.recency_days <= 30 AND f.frequency >= 10 AND m.monetary >= 5000 THEN 'Best Customers'
    WHEN r.recency_days <= 90 AND f.frequency >= 5 AND m.monetary >= 2000 THEN 'Loyal Customers'
    WHEN r.recency_days > 180 THEN 'At-Risk Customers'
    ELSE 'Regular Customers'
  END AS rfm_segmen
FROM recency r
JOIN frequency f ON r.customer_id = f.customer_id
JOIN monetary m ON r.customer_id = m.customer_id
ORDER BY m.monetary DESC;


