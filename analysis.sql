-- Example SQL queries for Olist data analysis

-- Count of orders by status
SELECT order_status, COUNT(*) as count
FROM orders
GROUP BY order_status
ORDER BY count DESC;

-- Average delivery time by product category
SELECT 
    p.product_category_name,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) as avg_delivery_days
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY avg_delivery_days DESC;

-- Monthly revenue
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') as month,
    SUM(payment_value) as total_revenue
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY month
ORDER BY month; 