CREATE TABLE  products (
	order_id VARCHAR(10),
	customer_id	VARCHAR(10),
	product_id VARCHAR(10),
	store_id VARCHAR(10),
	quantity INTEGER,
	unit_price	NUMERIC,
	discount NUMERIC,
	order_date	DATE,
	payment_method TEXT,
	status	TEXT,
	raw_notes TEXT,
	customer_name TEXT,
	customer_email VARCHAR(50),
	customer_city TEXT,
	customer_age INT,
	product_name TEXT,
	category TEXT,
	brand VARCHAR(10),
	store_name TEXT,
	store_city TEXT,
	store_manager VARCHAR(50)
);
-- verify if all rows are inserted
SELECT * FROM products
/* It is good practice to model the data in way 
 it is easy to alter*/

-- create customer dimension table
CREATE TABLE dim_customer AS (
	SELECT customer_id, 
		customer_name,
		customer_email,
		customer_city,
		customer_age
	FROM product
);

-- delete all rows because customers ID is not unique
TRUNCATE dim_customer;

-- insert unique customer data
INSERT INTO dim_customer(customer_id,
 customer_name,
  customer_email, 
  customer_city, 
  customer_age)
  SELECT DISTINCT customer_id, customer_name,
  customer_email,
  customer_city,
  customer_age
  FROM product;

--create product dimension
CREATE TABLE dim_product AS (
	SELECT DISTINCT product_id,
		product_name,
		category,
		brand
FROM product
);

--create store dimension 
CREATE TABLE dim_store AS (
	SELECT DISTINCT store_id,
		store_name,
		store_city,
		store_manager
FROM product
);

--create fact table
CREATE TABLE fact_sales AS (
SELECT pr.order_date,
	pr.order_id, 
	c.customer_id,
	p.product_id,
	s.store_id,
	pr.payment_method,
	pr.quantity,
	pr.unit_price,
	pr.discount,
	pr.status,
	pr.raw_notes
FROM product AS pr
JOIN dim_customer AS c ON pr.customer_id = c.customer_id
JOIN dim_product AS p ON pr.product_id = p.product_id
JOIN dim_store AS s ON pr.store_id = s.store_id
);

SELECT COUNT(DISTINCT order_id) FROM fact_sales

--create primary keys to dimenson tables
ALTER TABLE dim_customer ADD PRIMARY KEY (customer_id);
ALTER TABLE dim_product ADD PRIMARY KEY (product_id);
ALTER TABLE dim_store ADD PRIMARY KEY (store_id);
ALTER TABLE fact_sales ADD PRIMARY KEY (order_id);

--create forein keys to fact table
ALTER TABLE fact_sales
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES dim_customer (customer_id);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES dim_product (product_id);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_store
FOREIGN KEY (store_id)
REFERENCES dim_store (store_id);

--cost is about 0.65 so update cost for profit.
ALTER TABLE fact_sales
ADD COLUMN expenses NUMERIC;

UPDATE fact_sales
SET expenses = quantity*unit_price*0.65;

ALTER TABLE fact_sales
ADD COLUMN revenue NUMERIC;

UPDATE fact_sales
SET revenue = quantity*unit_price*(1-discount);

-- Total profit
SELECT SUM(Revenue - expenses)
FROM fact_sales;

-- check sales period
SELECT MIN(order_date), MAX(order_date)
FROM fact_sales;


-- generate sales over months 
WITH months AS(
	SELECT generate_series('2024-04-01', '2025-05-01', '1 month':: interval) as month
)
SELECT month,
	SUM((quantity*unit_price)*(1-discount)) AS revenue
FROM months AS m
INNER JOIN fact_sales AS s ON month = date_trunc('month', order_date)
GROUP BY month;

-- product contribute to most product
SELECT p.product_name as product,
	ROUND(SUM((quantity*unit_price)*(1-discount)),2) AS revenue
FROM dim_product AS p
INNER JOIN fact_sales AS s ON p.product_id = s.product_id
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;

--Create view with revenue column
CREATE OR REPLACE VIEW sales_view AS 
	SELECT *, (quantity*unit_price)*(1-discount) AS revenue
FROM fact_sales;



-- Average order value
SELECT c.customer_id, c.customer_name, COUNT(order_id) AS number_of_orders, 
	ROUND(SUM((quantity*unit_price)*(1-discount)),2) AS revenue,
	ROUND(SUM((quantity*unit_price)*(1-discount)) / COUNT(order_id), 2) AS Average_order_value
FROM dim_customer AS c 
INNER JOIN fact_sales AS f ON c.customer_id = f.customer_id
GROUP BY c.customer_id, c.customer_name;

--stores generating most outcomes
SELECT s.store_id, store_name,
	ROUND(SUM((f.quantity * f.unit_price)*(1-discount))) AS revenue
FROM dim_store AS s 
INNER JOIN fact_sales AS f ON s.store_id = f.store_id
GROUP BY s.store_id, store_name
ORDER BY revenue DESC
LIMIT 10;

--min and max discount
SELECT MIN(discount), MAX(discount) FROM fact_sales

--create segments for discount
CREATE OR REPLACE VIEW discount_sales AS
SELECT *,
	CASE WHEN discount = 0 AND discount <= 0.05 THEN 'less 5%'
		WHEN discount > 0.05 AND discount <= 0.10 THEN 'less 10%'
		WHEN discount > 0.10 AND discount <= 0.15 THEN 'less 15%'
		ELSE 'above 15%'
		END AS discount_segmentation
FROM fact_sales;

SELECT * FROM discount_sales

--discount vs quantity
SELECT discount_segmentation,
	ROUND(AVG(quantity),2) AS Avg_units_sold
FROM discount_sales
GROUP BY discount_segmentation
ORDER BY avg_units_sold DESC;

--which products has high discount
SELECT product_name,
	ROUND(AVG(discount),2) AS Avg_discount
FROM dim_product p
INNER JOIN fact_sales f ON p.product_id	= f.product_id
GROUP BY product_name
ORDER BY avg_discount DESC;

--avg discount and how it affect affect profit
SELECT ROUND(AVG(discount),2) AS av_discount,
	ROUND(1 - AVG(discount),2) AS Avg_profit_margin
FROM fact_sales;

--orders status distribution
SELECT status, 
	COUNT(*) AS order_count,
	ROUND(COUNT(*)*100 / SUM(COUNT(*)) OVER(),2) AS percentage
FROM fact_sales
GROUP BY status;

--which store has most cancelled
SELECT s.store_id, store_name, store_city,
	COUNT(order_id) AS cancelled_orders
FROM dim_store s
INNER JOIN fact_sales f ON s.store_id = f.store_id
WHERE status = 'Cancelled'
GROUP BY s.store_id, store_name, store_city
ORDER BY cancelled_orders DESC
LIMIT 5;

-- Where should we open new stores based on customer location density and demand?
SELECT customer_city AS city, COUNT(customer_id) AS customers,
	(SELECT COUNT(store_id) FROM dim_store) AS Number_stores
FROM dim_customer
GROUP BY customer_city
ORDER BY customers DESC;



