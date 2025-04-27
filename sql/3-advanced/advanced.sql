-- Answer all the questions below with advanced SQL queries (partitioning, CASE WHENs)
-- don't forget to add a screenshot of the result from BigQuery directly in the basics/ folder

-- 1. Where are located the clients that ordered more than the average?

    -- SELECT 
    -- c.customer_city,
    -- Count(DISTINCT o.order_id) as nb_orders
    -- FROM `olist_orders_dataset` as o
    -- JOIn `olist_customers_dataset` as c
    -- ON o.customer_id = c.customer_id
    -- WHERE nb_orders > AVG(count(DISTINCT o.order_id))
    -- GROUP by customer_city


WITH order_counts AS (
    SELECT 
    c.customer_city,
    COUNT(o.order_id) as nb_orders
    FROM `olist_orders_dataset` as o
    JOIN `olist_customers_dataset` as c
    ON o.customer_id = c.customer_id
    GROUP BY customer_city
),
avg_orders AS (
    SELECT AVG(nb_orders) as avg_nb_orders 
    FROM order_counts
)
SELECT 
    customer_city,
    nb_orders
FROM order_counts
JOIN avg_orders
WHERE nb_orders > avg_nb_orders
ORDER BY nb_orders DESC

-- 2. Segment clients in categories based on the amount spent (use CASE WHEN)

SELECT
c.customer_id,
ROUND(sum(p.payment_value),2) as total_spent,
CASE
WHEN sum(p.payment_value) > 1000 THEN 'High Value Customer'
WHEN sum(p.payment_value) > 500 THEN 'Medium Value Customer'
ELSE 'Low Value Customer'
END as customer_segment
FROM `olist_customers_dataset` as c
JOIN `olist_orders_dataset` as o
ON c.customer_id = o.customer_id
JOIN `olist_order_payments_dataset` as p
ON o.order_id = p.order_id
GROUP By c.customer_id
ORDER BY total_spent DESC


-- 3. Compute the difference in days between the first and last order of a client. Compute then the average (use PARTITION BY)

SELECT
  o.customer_id,
  o.order_id,
  CAST(
    julianday(o.order_delivered_customer_date) 
    - julianday(o.order_purchase_timestamp)
    AS INTEGER
  ) AS days_between_orders,
  AVG(CAST(
    julianday(o.order_delivered_customer_date)
    - julianday(o.order_purchase_timestamp) 
    AS INTEGER
  )) OVER (PARTITION BY o.customer_id) as avg_days_between_orders
FROM
  olist_orders_dataset AS o
ORDER BY customer_id, days_between_orders DESC



-- 4. Add a column to the query in basics question 2.: what was their first product category purchased?


WITH first_product_per_customer AS (
  SELECT
    c.customer_id,
    p.product_category_name
  FROM `olist_customers_dataset` AS c
  JOIN `olist_orders_dataset` AS o ON c.customer_id = o.customer_id
  JOIN `olist_order_items_dataset` AS oi ON o.order_id = oi.order_id
  JOIN `olist_products_dataset` AS p ON oi.product_id = p.product_id
  WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp = (
      SELECT MIN(o2.order_purchase_timestamp)
      FROM `olist_orders_dataset` AS o2
      WHERE o2.customer_id = c.customer_id
        AND o2.order_status = 'delivered'
    )
)

SELECT 
  c.customer_id,
  c.customer_unique_id,
  c.customer_city,
  fppc.product_category_name AS first_product_category
FROM `olist_customers_dataset` AS c
JOIN `olist_orders_dataset` AS o ON c.customer_id = o.customer_id
JOIN first_product_per_customer fppc ON c.customer_id = fppc.customer_id
WHERE o.order_status = 'delivered'
ORDER BY o.order_delivered_customer_date DESC
LIMIT 5;



