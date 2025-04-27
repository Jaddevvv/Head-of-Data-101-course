-- Answer all the questions below with aggegate SQL queries
-- don't forget to add a screenshot of the result from BigQuery directly in the basics/ folder

-- 1. What was the total revenue and order count for 2018?

SELECT sum(p.payment_value)
FROM `olist_order_payments_dataset` as p
JOIN `olist_orders_dataset` as o
ON o.order_id = p.order_id
WHERE EXTRACT(YEAR FROM CAST(o.order_delivered_customer_date AS DATE)) = 2018;


-- 2. What is the total_sales, average_order_sales, and first_order_date by customer? 
-- Round the values to 2 decimal places & order by total_sales descending
-- limit to 1000 results

SELECT
c.customer_id,
c.customer_unique_id,
ROUND(SUM(p.payment_value),2) as total_sales,
ROUND(AVG(p.payment_value),2) as average_order_sales,
ROUND(MIN(o.order_purchase_timestamp),2) as first_order_date
FROM `olist_customers_dataset` as c
JOIN `olist_orders_dataset` as o
ON c.customer_id = o.customer_id
JOIN `olist_order_payments_dataset` as p
ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_unique_id
ORDER BY total_sales DESC
LIMIT 1000



-- 3. Who are the top 10 most successful sellers?

SELECT
s.seller_id,
SUM(p.payment_value) as total_sales
FROM `olist_sellers_dataset` as s
JOIN `olist_order_items_dataset` as oi
ON s.seller_id = oi.seller_id
JOIN `olist_order_payments_dataset` as p
ON oi.order_id = p.order_id
GROUP BY s.seller_id
ORDER BY total_sales DESC
LIMIT 10

-- 4. What’s the preferred payment method by product category?

SELECT
p.product_category_name,
COUNT(pm.payment_type) as payment_occurence
FROM `olist_products_dataset` as p
JOIN `olist_order_items_dataset` as oi
ON p.product_id = oi.product_id
JOIN `olist_order_payments_dataset` as pm
ON oi.order_id = pm.order_id
GROUP BY
  p.product_category_name
ORDER BY
  payment_occurence DESC;
