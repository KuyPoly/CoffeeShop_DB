/***************************************************************
************************* VIEW DEFINITIONS **********************
****************************************************************/
USE coffee_shop;
-- ==================== CORE BUSINESS VIEWS ====================

-- 1. Employee Information View
-- Provides comprehensive details about employees including their roles and managers
CREATE OR REPLACE VIEW employee_info AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.role_name,
    r.hour_salary,
    e.start_date,
    e.phone_number,
    e.address,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
JOIN role r ON e.role_id = r.role_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- Should show all employees with correct role assignments
SELECT * FROM employee_info;

-- 2. Product Details View
-- Shows product information with categories and ingredients
CREATE OR REPLACE VIEW product_details AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    GROUP_CONCAT(i.name SEPARATOR ', ') AS ingredients
FROM products p
JOIN category c ON p.category_id = c.category_id
JOIN product_ingredient pi ON p.product_id = pi.product_id
JOIN inventory i ON pi.inventory_id = i.inventory_id
GROUP BY p.product_id, p.product_name, c.category_name, p.price;

--  Should show espresso, matcha latte, pumpkin spice with ingredients
SELECT * FROM product_details WHERE product_id IN (1, 6, 11);

-- ==================== SALES ANALYSIS VIEWS ====================

-- 3. Daily Sales Summary View
-- Aggregates sales data by day for performance tracking
CREATE OR REPLACE VIEW daily_sales AS
SELECT 
    o.date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total) AS total_revenue,
    SUM(oi.quantity) AS total_items_sold,
    GROUP_CONCAT(DISTINCT p.product_name SEPARATOR ', ') AS products_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.date
ORDER BY o.date;

-- Should show 2 orders totaling $8.50 + $12.75 = $21.25
SELECT * FROM daily_sales WHERE date = '2023-10-02';

-- 4. Customer Favorites View
-- Identifies most popular products based on order frequency
CREATE OR REPLACE VIEW customer_favorites AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    COUNT(oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN category c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_quantity_sold DESC;

-- Should show most ordered products by quantity
SELECT * FROM customer_favorites LIMIT 3;

-- ==================== OPERATIONAL VIEWS ====================

-- 6. Employee Shift Schedule View
-- Displays all scheduled shifts with calculated hours worked
CREATE OR REPLACE VIEW employee_schedule AS
SELECT 
    es.shift_date,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.role_name,
    es.shift_start,
    es.shift_end,
    TIMESTAMPDIFF(HOUR, es.shift_start, es.shift_end) AS hours_worked
FROM employee_shift es
JOIN employees e ON es.employee_id = e.employee_id
JOIN role r ON e.role_id = r.role_id
ORDER BY es.shift_date, es.shift_start;

-- Should show 8-hour shift for employee 2
SELECT * FROM employee_schedule WHERE shift_date = '2023-10-02';

-- 7. Inventory Status View
-- Provides current inventory levels with restock information
CREATE OR REPLACE VIEW inventory_status AS
SELECT 
    i.name,
    i.quantity,
    i.unit,
    i.restock_date,
    s.name AS supplier,
    sp.price AS unit_price,
    CASE 
        WHEN i.quantity < 1000 AND i.unit = 'grams' THEN 'Low'
        WHEN i.quantity < 10 AND i.unit = 'liters' THEN 'Low'
        WHEN i.quantity < 500 AND i.unit = 'ml' THEN 'Low'
        ELSE 'Adequate'
    END AS stock_level
FROM inventory i
JOIN supplier_product sp ON i.inventory_id = sp.inventory_id
JOIN supplier s ON sp.supplier_id = s.supplier_id;

-- Should show current coffee bean stock level
SELECT * FROM inventory_status WHERE name = 'Coffee Beans';

-- 8. Ingredient Usage Report View
-- Tracks ingredient consumption and remaining stock percentages
CREATE OR REPLACE VIEW ingredient_usage_report AS
SELECT 
    i.inventory_id,
    i.name AS ingredient_name,
    i.unit,
    SUM(pi.quantity_used * oi.quantity) AS total_used,
    i.quantity AS current_stock,
    ROUND((i.quantity / NULLIF(SUM(pi.quantity_used * oi.quantity), 0)) * 100, 2) AS remaining_percentage
FROM inventory i
JOIN product_ingredient pi ON i.inventory_id = pi.inventory_id
JOIN order_items oi ON pi.product_id = oi.product_id
GROUP BY i.inventory_id, i.name, i.unit, i.quantity
ORDER BY remaining_percentage ASC;

-- Should show milk usage percentage
SELECT * FROM ingredient_usage_report WHERE ingredient_name LIKE '%Milk%';

-- ==================== PERFORMANCE METRICS VIEWS ====================

-- 9. Top Selling Products View
-- Ranks products by sales quantity and revenue
CREATE OR REPLACE VIEW top_selling_products AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * p.price) AS total_revenue
FROM products p
JOIN category c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_quantity_sold DESC;

-- Should show Pumpkin Spice Latte sales
SELECT * FROM top_selling_products WHERE product_id = 11;

-- 10. Employee Performance View
-- Measures employee productivity and sales performance
CREATE OR REPLACE VIEW employee_performance AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.role_name,
    COUNT(o.order_id) AS total_orders_processed,
    SUM(o.total) AS total_sales_amount,
    COUNT(DISTINCT es.shift_date) AS days_worked,
    SUM(TIMESTAMPDIFF(HOUR, es.shift_start, es.shift_end)) AS total_hours_worked,
    SUM(o.total) / NULLIF(COUNT(DISTINCT es.shift_date), 0) AS avg_sales_per_day
FROM employees e
JOIN role r ON e.role_id = r.role_id
LEFT JOIN orders o ON e.employee_id = o.employee_id
LEFT JOIN employee_shift es ON e.employee_id = es.employee_id
GROUP BY e.employee_id, employee_name, r.role_name;

-- Should show Sarah Lee's performance stats
SELECT * FROM employee_performance WHERE employee_id = 2;

-- 11. Employee Sales Comparison View
-- Compares sales performance across employees
CREATE OR REPLACE VIEW employee_sales_comparison AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.role_name,
    COUNT(DISTINCT o.order_id) AS orders_processed,
    SUM(o.total) AS total_sales,
    AVG(o.total) AS average_order_value,
    SUM(o.total) / NULLIF(SUM(TIMESTAMPDIFF(HOUR, es.shift_start, es.shift_end)), 0) AS sales_per_hour
FROM employees e
JOIN role r ON e.role_id = r.role_id
LEFT JOIN orders o ON e.employee_id = o.employee_id
LEFT JOIN employee_shift es ON e.employee_id = es.employee_id
GROUP BY e.employee_id, employee_name, r.role_name
ORDER BY total_sales DESC;

-- Should show top performing employee
SELECT * FROM employee_sales_comparison ORDER BY total_sales DESC LIMIT 1;

-- ==================== BUSINESS INTELLIGENCE VIEWS ====================

-- 12. Product Cost Analysis View
-- Calculates cost, profit, and margin for each product
CREATE OR REPLACE VIEW product_cost_analysis AS
SELECT 
    p.product_id,
    p.product_name,
    p.price AS selling_price,
    ROUND(SUM(pi.quantity_used * sp.price), 2) AS cost_per_unit,
    ROUND(p.price - SUM(pi.quantity_used * sp.price), 2) AS profit_per_unit,
    ROUND((p.price - SUM(pi.quantity_used * sp.price)) / p.price * 100, 2) AS profit_margin
FROM products p
JOIN product_ingredient pi ON p.product_id = pi.product_id
JOIN inventory i ON pi.inventory_id = i.inventory_id
JOIN supplier_product sp ON i.inventory_id = sp.inventory_id
GROUP BY p.product_id, p.product_name, p.price;

-- Should show espresso cost breakdown
SELECT * FROM product_cost_analysis WHERE product_id = 1;

-- 13. Supplier Performance View
-- Evaluates suppliers based on pricing and product range
CREATE OR REPLACE VIEW supplier_performance AS
SELECT 
    s.supplier_id,
    s.name AS supplier_name,
    COUNT(DISTINCT sp.inventory_id) AS products_supplied,
    AVG(sp.price) AS average_price,
    MIN(sp.price) AS lowest_price,
    MAX(sp.price) AS highest_price
FROM supplier s
JOIN supplier_product sp ON s.supplier_id = sp.supplier_id
GROUP BY s.supplier_id, s.name
ORDER BY average_price;

-- Should show coffee bean supplier stats
SELECT * FROM supplier_performance WHERE supplier_name LIKE '%Bean%';

-- 14. Product Pairing Analysis View
-- Reveals which products are frequently ordered together
CREATE OR REPLACE VIEW product_pairings AS
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_ordered_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) > 1
ORDER BY times_ordered_together DESC;

-- Should show top product combinations
SELECT * FROM product_pairings LIMIT 3;
