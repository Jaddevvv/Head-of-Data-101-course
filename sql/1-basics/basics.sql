-- Answer all the questions below with basics SQL queries
-- don't forget to add a screenshot of the result from BigQuery directly in the basics/ folder

-- 1. What are the possible values of an order status? 

SELECT
DISTINCT order_status
FROM `olist_orders_dataset`

-- -- 2. Who are the 5 last customers that purchased a DELIVERED order (order with status DELIVERED)?
-- -- print their customer_id, their unique_id, and city

SELECT c.customer_id,c.customer_unique_id,c.customer_city
FROM `BRONZE.customers` as c
JOIN `BRONZE.orders` as o
ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
Order by o.order_delivered_customer_date DESC
LIMIT 5

-- -- 3. Add a column is_sp which returns 1 if the customer is from São Paulo and 0 otherwise

SELECT
c.customer_id,
c.customer_unique_id,
c.customer_city,
CASE
WHEN c.customer_city = 'São Paulo' THEN 1
ELSE 0
END as is_sp
FROM `BRONZE.customers` as c


-- -- 4. add a new column: what's the product category associated to the order?

SELECT c.customer_id,
c.customer_unique_id,
c.customer_city,
p.product_category_name
FROM `olist_customers_dataset` as c
JOIN `olist_orders_dataset` as o
ON o.customer_id = c.customer_id
JOIN `olist_order_items_dataset` as oi
ON o.order_id = oi.order_id
JOIN `olist_products_dataset` as p
ON oi.product_id = p.product_id


