USE coffee_shop;

/* *************************************************************** 
	*************************** View ************************
**************************************************************** */

USE coffee_shop;

-- -----------------------------
-- DROP Old Views (to avoid errors)
-- -----------------------------
DROP VIEW IF EXISTS aggregated_sales;
DROP VIEW IF EXISTS daily_sales_report;
DROP VIEW IF EXISTS employee_sales_performance;
DROP VIEW IF EXISTS customer_order_history;
DROP VIEW IF EXISTS product_popularity;
DROP VIEW IF EXISTS category_sales_report;
DROP VIEW IF EXISTS low_stock_report;
DROP VIEW IF EXISTS monthly_top_products;
DROP VIEW IF EXISTS customer_frequent_purchases;
DROP VIEW IF EXISTS order_peak_hours;
DROP VIEW IF EXISTS avg_spending_per_day;

-- -----------------------------
-- 1. Aggregated Weekly Sales
-- -----------------------------
CREATE VIEW aggregated_sales AS
SELECT 
    YEARWEEK(o.date, 1) AS sales_week,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total) AS total_revenue
FROM orders o
GROUP BY YEARWEEK(o.date, 1);

-- -----------------------------
-- 2. Daily Sales Report (kept as is)
-- -----------------------------
CREATE VIEW daily_sales_report AS
SELECT 
    DATE(o.date) AS sale_date, 
    SUM(o.total) AS total_revenue, 
    COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY DATE(o.date);

-- -----------------------------
-- 3. Employee Shift Hours Report
-- (Assumes a `shifts` table exists)
-- -----------------------------
CREATE VIEW employee_sales_performance AS
SELECT 
    e.employee_id, 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
    SUM(TIMESTAMPDIFF(HOUR, s.shift_start, s.shift_end)) AS total_shift_hours
FROM employees e
JOIN shifts s ON e.employee_id = s.employee_id
GROUP BY e.employee_id, employee_name
ORDER BY total_shift_hours DESC;

-- -----------------------------
-- 4. Customer Order History (Grouped by Order)
-- -----------------------------
CREATE VIEW customer_order_history AS
SELECT 
    o.order_id, 
    o.date AS order_date, 
    o.total AS order_total, 
    COUNT(oi.product_id) AS total_items,
    SUM(oi.quantity) AS total_quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.date, o.total
ORDER BY o.date DESC;

-- -----------------------------
-- 5. Product Popularity
-- -----------------------------
CREATE VIEW product_popularity AS
SELECT 
    oi.product_id, 
    p.product_name, 
    SUM(oi.quantity) AS total_sold,
    COUNT(oi.order_id) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_sold DESC;

-- -----------------------------
-- 6. Category Sales Report
-- -----------------------------
CREATE VIEW category_sales_report AS
SELECT 
    c.category_id, 
    c.category_name, 
    SUM(oi.quantity * p.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- -----------------------------
-- 7. Low Stock Report
-- -----------------------------
CREATE VIEW low_stock_report AS
SELECT 
    i.inventory_id, 
    i.name AS product_name, 
    i.quantity, 
    i.restock_date
FROM inventory i
WHERE i.quantity < 10
ORDER BY i.quantity ASC;

-- -----------------------------
-- 8. Monthly Top Products
-- -----------------------------
CREATE VIEW monthly_top_products AS
SELECT 
    DATE_FORMAT(o.date, '%Y-%m') AS sale_month,
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY sale_month, p.product_id, p.product_name
ORDER BY sale_month, total_sold DESC;

-- -----------------------------
-- 9. Customer Frequent Purchases
-- (Requires `customers` table)
-- -----------------------------
CREATE VIEW customer_frequent_purchases AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_orders DESC;

-- -----------------------------
-- 10. Order Peak Hours
-- -----------------------------
CREATE VIEW order_peak_hours AS
SELECT 
    HOUR(o.date) AS order_hour,
    COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY order_hour
ORDER BY total_orders DESC;

-- -----------------------------
-- 11. Average Spending per Day
-- -----------------------------
CREATE VIEW avg_spending_per_day AS
SELECT 
    DATE(o.date) AS sale_date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total) AS total_revenue,
    ROUND(AVG(o.total), 2) AS avg_order_value
FROM orders o
GROUP BY DATE(o.date)
ORDER BY sale_date DESC;

-- -----------------------------
-- View List Check
-- -----------------------------
SHOW FULL TABLES IN coffee_shop 
WHERE TABLE_TYPE = 'VIEW';
