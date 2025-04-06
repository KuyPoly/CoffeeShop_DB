USE coffee_shop;

/* *************************************************************** 
	*************************** DQL ************************
**************************************************************** */

-- Get All Products with Their Categories
SELECT p.product_id, p.product_name, c.category_name, p.price
FROM products p
JOIN category c ON p.category_id = c.category_id;

-- Get All Employees and Their Roles and Their salary
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.role_name,
    r.hour_salary,
    SUM(TIMESTAMPDIFF(HOUR, s.shift_start, s.shift_end)) AS total_hours_worked,
    SUM(TIMESTAMPDIFF(HOUR, s.shift_start, s.shift_end) * r.hour_salary) AS total_salary
FROM employees e
JOIN role r ON e.role_id = r.role_id
JOIN employee_shift s ON e.employee_id = s.employee_id
GROUP BY e.employee_id, r.role_name, r.hour_salary
ORDER BY e.employee_id;

-- Get Employee Shifts with Start and End Times
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    s.shift_date,
    s.shift_start,
    s.shift_end
FROM employee_shift s
JOIN employees e ON s.employee_id = e.employee_id
ORDER BY s.shift_date, s.shift_start;


-- Get Total Sales by Each Employee
SELECT e.employee_id, e.first_name, e.last_name, SUM(o.total) AS total_sales
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_sales DESC;

-- Get Best-Selling Products (Top 5)
SELECT p.product_name, SUM(oi.quantity) AS total_sold, ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;

-- Get Least-Selling Products (Bottom 5)
SELECT p.product_name, SUM(oi.quantity) AS total_sold, ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold ASC
LIMIT 5;

-- Get Suppliers and Their Products
SELECT s.name AS supplier_name, i.name AS inventory_item, sp.price
FROM supplier_product sp
JOIN supplier s ON sp.supplier_id = s.supplier_id
JOIN inventory i ON sp.inventory_id = i.inventory_id;

-- Get Low-Stock Inventory Items (Threshold: 100)
SELECT * FROM inventory
WHERE quantity < 1000;

-- Get Total Hours Worked by Each Employee (From employee_shift)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE, s.shift_start, s.shift_end)/60), 2) AS total_hours
FROM employee_shift s
JOIN employees e ON s.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name;

-- Get Top 3 Earning Products (By Revenue)
SELECT 
    p.product_name,
    SUM(oi.quantity * p.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 3;

-- Get Inventory Usage per Product (From product_ingredient)
SELECT 
    p.product_name,
    i.name AS ingredient,
    pi.quantity_used,
    i.unit
FROM product_ingredient pi
JOIN products p ON pi.product_id = p.product_id
JOIN inventory i ON pi.inventory_id = i.inventory_id
ORDER BY p.product_name;
