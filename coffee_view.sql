USE coffee_shop;

/* *************************************************************** 
	*************************** View ************************
**************************************************************** */

-- View for Aggregated Sales Data
CREATE VIEW aggregated_sales AS
SELECT 
    DATE(o.date) AS sale_date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total) AS total_revenue
FROM orders o
GROUP BY DATE(o.date);

select * from aggregated_sales;

-- View for Customer Order History (if customer table exists)
-- If there is no customer table, this will just track orders
CREATE VIEW customer_order_history AS
SELECT 
    o.order_id, 
    o.date AS order_date, 
    o.total AS order_total, 
    oi.product_id, 
    p.product_name, 
    oi.quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.date DESC;

SELECT * FROM customer_order_history;

-- View for Product Popularity
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

SELECT * FROM product_popularity;

-- View for Daily Sales Report
CREATE VIEW daily_sales_report AS
SELECT 
    DATE(o.date) AS sale_date, 
    SUM(o.total) AS total_revenue, 
    COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY DATE(o.date);

SELECT * FROM daily_sales_report;

-- View for Employee Sales Performance
CREATE VIEW employee_sales_performance AS
SELECT 
    e.employee_id, 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
    COUNT(o.order_id) AS total_orders, 
    SUM(o.total) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY e.employee_id, employee_name
ORDER BY total_revenue DESC;

SELECT * FROM employee_sales_performance;

-- View for Category Sales Report
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

SELECT * FROM category_sales_report;

-- View for Low Stock Report
CREATE VIEW low_stock_report AS
SELECT 
    i.inventory_id, 
    i.name AS product_name, 
    i.quantity, 
    i.restock_date
FROM inventory i
WHERE i.quantity < 10
ORDER BY i.quantity ASC;

SELECT * FROM low_stock_report;

-- Show all of the views
SHOW FULL TABLES IN coffee_shop 
WHERE TABLE_TYPE = 'VIEW';