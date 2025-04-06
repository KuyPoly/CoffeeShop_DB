use coffee_shop;
-- 1. Employees & Roles
-- add new employee
DELIMITER //
CREATE PROCEDURE AddNewEmployee(
    IN first_name VARCHAR(25),
    IN last_name VARCHAR(25),
    IN start_date DATE,
    IN role_id INT,
    IN phone_number VARCHAR(20),
    IN address VARCHAR(30),
    IN manager_id INT
)
BEGIN
    INSERT INTO employees (first_name, last_name, start_date, role_id, phone_number, address, manager_id)
    VALUES (first_name, last_name, start_date, role_id, phone_number, address, manager_id);
END //
DELIMITER ;

CALL AddNewEmployee('John', 'Doe', '2025-04-01', 2, '123-456-7890', '123 Main St', 1);

-- update employee role
DELIMITER //

CREATE PROCEDURE UpdateEmployeeRole(
    IN emp_id INT,
    IN new_role_id INT
)
BEGIN
    UPDATE employees
    SET role_id = new_role_id
    WHERE employee_id = emp_id;
END //

DELIMITER ;
CALL UpdateEmployeeRole(1, 3);  -- Updates employee with ID 1 to role ID 3

-- delete employee
DELIMITER //

CREATE PROCEDURE DeleteEmployee(
    IN emp_id INT
)
BEGIN
    DELETE FROM employees
    WHERE employee_id = emp_id;
END //

DELIMITER ;
CALL DeleteEmployee(1);  -- Deletes employee with ID 1

-- list all employee with managers
DELIMITER //

CREATE PROCEDURE ListAllEmployeesWithManagers()
BEGIN
    SELECT e.first_name AS employee_name, m.first_name AS manager_name
    FROM employees e
    LEFT JOIN employees m ON e.manager_id = m.employee_id;
END //

DELIMITER ;
CALL ListAllEmployeesWithManagers();

-- employee function
-- get employee full name
DELIMITER //

CREATE FUNCTION GetEmployeeFullName(emp_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(50);
    SELECT CONCAT(first_name, ' ', last_name) INTO full_name
    FROM employees
    WHERE employee_id = emp_id;
    RETURN full_name;
END //

DELIMITER ;
SELECT GetEmployeeFullName(2);  -- Retrieves full name for employee ID 1

-- get employee role name
DELIMITER //

CREATE FUNCTION GetEmployeeRoleName(emp_id INT)
RETURNS VARCHAR(25)
DETERMINISTIC
BEGIN
    DECLARE role_name VARCHAR(25);
    SELECT r.role_name INTO role_name
    FROM employees e
    JOIN role r ON e.role_id = r.role_id
    WHERE e.employee_id = emp_id;
    RETURN role_name;
END //

DELIMITER ;

SELECT GetEmployeeRoleName(2);  -- Retrieves role name for employee ID 1

-- 2. Shifts
-- Assign Shift to Employee:
DELIMITER //

CREATE PROCEDURE AssignShift(
    IN emp_id INT,
    IN shift_date DATE,
    IN shift_start TIME,
    IN shift_end TIME
)
BEGIN
    INSERT INTO employee_shift (employee_id, shift_date, shift_start, shift_end)
    VALUES (emp_id, shift_date, shift_start, shift_end);
END //

DELIMITER ;
CALL AssignShift(2, '2025-04-05', '08:00:00', '16:00:00');

-- Get Employee Shifts:
DELIMITER //

CREATE PROCEDURE GetEmployeeShifts(
    IN emp_id INT,
    IN from_date DATE,
    IN to_date DATE
)
BEGIN
    SELECT shift_date, shift_start, shift_end
    FROM employee_shift
    WHERE employee_id = emp_id
    AND shift_date BETWEEN from_date AND to_date;
END //

DELIMITER ;
CALL GetEmployeeShifts(1, '2025-04-01', '2025-04-10');

-- Update Shift Time:
DELIMITER //

CREATE PROCEDURE UpdateShiftTime(
    IN p_shift_id INT,
    IN new_start TIME,
    IN new_end TIME
)
BEGIN
    UPDATE employee_shift
    SET shift_start = new_start, shift_end = new_end
    WHERE shift_id = p_shift_id;
END //

DELIMITER ;
CALL UpdateShiftTime(3, '09:00:00', '17:00:00');

-- Functions
-- Get Total Shift Hours:
DELIMITER //

CREATE FUNCTION GetTotalShiftHours(emp_id INT, month INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_hours DECIMAL(10,2);
    SELECT SUM(TIMESTAMPDIFF(HOUR, shift_start, shift_end)) INTO total_hours
    FROM employee_shift
    WHERE employee_id = emp_id AND MONTH(shift_date) = month;
    RETURN total_hours;
END //

DELIMITER ;
SELECT GetTotalShiftHours(2, 04);  -- Get total hours worked by employee ID 1 in April

-- Check if Employee is Working:
DELIMITER //

CREATE FUNCTION IsEmployeeWorking(
    emp_id INT,
    f_shift_date DATE
)
RETURNS TINYINT(1)
DETERMINISTIC
BEGIN
    DECLARE is_working TINYINT(1);
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO is_working
    FROM employee_shift
    WHERE employee_id = emp_id AND shift_date = f_shift_date;
    RETURN is_working;
END //

DELIMITER ;

SELECT IsEmployeeWorking(2, '2023-07-01');  -- Check if employee ID 1 is working on 2023-07-01

-- 3. Orders & Order Items
-- Add Full Order:
DELIMITER //

CREATE PROCEDURE AddFullOrder(
    IN order_date DATE,
    IN total_amt DECIMAL(10,2),
    IN method INT,
    IN emp_id INT,
    IN prod1 INT, IN qty1 INT,
    IN prod2 INT, IN qty2 INT
)
BEGIN
    DECLARE new_order_id INT;

    INSERT INTO orders (date, total, method_id, employee_id)
    VALUES (order_date, total_amt, method, emp_id);

    SET new_order_id = LAST_INSERT_ID();

    INSERT INTO order_items (order_id, product_id, quantity)
    VALUES 
    (new_order_id, prod1, qty1),
    (new_order_id, prod2, qty2);
END //

DELIMITER ;
CALL AddFullOrder('2025-04-05', 100.00, 1, 2, 1, 2, 2, 3);

-- Cancel Order:
DELIMITER //

CREATE PROCEDURE CancelOrder(
    IN p_order_id INT
)
BEGIN
    DELETE FROM order_items WHERE order_id = order_id;
    DELETE FROM orders WHERE order_id = p_order_id;
END //

DELIMITER ;
call CancelOrder(8);

-- Daily Sales Report:
DELIMITER //

CREATE PROCEDURE DailySalesReport(
    IN p_report_date DATE
)
BEGIN
    SELECT SUM(o.total) AS total_sales, COUNT(o.order_id) AS total_orders
    FROM orders o
    WHERE o.date = p_report_date;
END //

DELIMITER ;
CALL DailySalesReport('2025-04-05');

-- Functions
-- Get Order Total:
DELIMITER //

CREATE FUNCTION GetOrderTotal(order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(oi.quantity * p.price) INTO total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = order_id;
    RETURN total;
END //

DELIMITER ;
SELECT GetOrderTotal(9);  -- Retrieves the total amount for order ID 1

-- 4. Products & Categories
-- Add New Product
DELIMITER //

CREATE PROCEDURE AddProduct(
    IN name VARCHAR(20),
    IN cat_id INT,
    IN price DECIMAL(10,2)
)
BEGIN
    INSERT INTO products (product_name, category_id, price)
    VALUES (name, cat_id, price);
END //

DELIMITER ;
CALL AddProduct('Cappuccino', 1, 4.75);

-- Update Product Price:
DELIMITER //

CREATE PROCEDURE UpdateProductPrice(
    IN prod_id INT,
    IN new_price DECIMAL(10,2)
)
BEGIN
    UPDATE products
    SET price = new_price
    WHERE product_id = prod_id;
END //

DELIMITER ;
CALL UpdateProductPrice(1, 5.00);  -- Updates product with ID 1 to new price of 5.00

-- Delete Product
DELIMITER //

CREATE PROCEDURE DeleteProduct(
    IN prod_id INT
)
BEGIN
    DELETE FROM products WHERE product_id = prod_id;
END //

DELIMITER ;
CALL DeleteProduct(7);  -- Deletes product with ID 1

-- Functions
-- Get Product Category Name
DELIMITER //

CREATE FUNCTION GetProductCategoryName(prod_id INT)
RETURNS VARCHAR(25)
DETERMINISTIC
BEGIN
    DECLARE category_name VARCHAR(25);
    SELECT c.category_name INTO category_name
    FROM products p
    JOIN category c ON p.category_id = c.category_id
    WHERE p.product_id = prod_id;
    RETURN category_name;
END //

DELIMITER ;
SELECT GetProductCategoryName(5);  -- Retrieves the category name for product ID 1

-- Get Products by Category:
DELIMITER //

CREATE FUNCTION GetProductsByCategory(cat_id INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE product_list TEXT;
    SELECT GROUP_CONCAT(product_name) INTO product_list
    FROM products
    WHERE category_id = cat_id;
    RETURN product_list;
END //

DELIMITER ;
SELECT GetProductsByCategory(1);  -- Retrieves a list of products in category ID 1

-- 5. Inventory & Ingredients
-- Restock Inventory:
DELIMITER //

CREATE PROCEDURE RestockInventory(
    IN inv_id INT,
    IN qty INT
)
BEGIN
    UPDATE inventory
    SET quantity = quantity + qty
    WHERE inventory_id = inv_id;
END //

DELIMITER ;
CALL RestockInventory(1, 50);  -- Restocks inventory item with ID 1 by 50 units

-- Auto Restock Check(for check qauntity):
DELIMITER //

CREATE PROCEDURE AutoRestockCheck(
    IN min_qty INT
)
BEGIN
    SELECT inventory_id, name, quantity, unit
    FROM inventory
    WHERE quantity < min_qty;
END //

DELIMITER ;
CALL AutoRestockCheck(1000);  -- Finds all inventory items with quantity less than 10

-- List Ingredients for Product:
DELIMITER //

CREATE PROCEDURE ListIngredientsForProduct(
    IN prod_id INT
)
BEGIN
    SELECT i.name AS ingredient, pi.quantity_used
    FROM product_ingredient pi
    JOIN inventory i ON pi.inventory_id = i.inventory_id
    WHERE pi.product_id = prod_id;
END //

DELIMITER ;
CALL ListIngredientsForProduct(4);  -- Retrieves ingredients for product ID 1

 -- 6. Suppliers
-- Add New Supplier:
DELIMITER //

CREATE PROCEDURE AddSupplier(
	IN p_supplier_id int,
    IN p_contact_phone VARCHAR(20),
    IN p_address VARCHAR(30),
    IN p_supplier_name VARCHAR(25)
)
BEGIN
    INSERT INTO supplier (supplier_id, phone_number, address, name)
    VALUES (p_supplier_id, p_contact_phone, p_address, p_supplier_name);
END //

DELIMITER ;
CALL AddSupplier(4, '123-789-4560', '456 Supplier Rd','John Smith');


-- Update Supplier Information:
DELIMITER //

CREATE PROCEDURE UpdateSupplier(
    IN p_supplier_id INT,
    IN new_name VARCHAR(50),
    IN new_contact_phone VARCHAR(20),
    IN new_address VARCHAR(100)
)
BEGIN
    UPDATE supplier
    SET name = new_name,
        phone_number = new_contact_phone,
        address = new_address
    WHERE supplier_id = p_supplier_id;
END //

DELIMITER ;

CALL UpdateSupplier(1, 'Supplier B', '321-654-9870', '789 New Supplier Rd');

-- Delete Supplier:
DELIMITER //

CREATE PROCEDURE DeleteSupplier(
    IN p_supplier_id INT
)
BEGIN
    DELETE FROM supplier
    WHERE supplier_id = p_supplier_id;
END //

DELIMITER ;

CALL DeleteSupplier(7);  -- Deletes supplier with ID 1

-- Add Product from Supplier:
DELIMITER //

CREATE PROCEDURE AddProductFromSupplier(
    IN supplier_id INT,
    IN inventory_id INT,
    IN price DECIMAL(10, 2),
    IN time DATETIME
)
BEGIN
    -- Insert product from supplier
    INSERT INTO supplier_product (supplier_id, inventory_id, price, time)
    VALUES (supplier_id, inventory_id, price, time);
END //

DELIMITER ;

CALL AddProductFromSupplier(2, 2, 50.00, '2025-04-05 10:00:00');


-- List Products for Supplier:
DELIMITER //

CREATE PROCEDURE ListProductsFromSupplier(
    IN supplier_id INT
)
BEGIN
    SELECT 
        sp.supplier_product_id, 
        pi.product_id,
        i.name AS product_name, 
        sp.price, 
        sp.time
    FROM supplier_product sp
    JOIN inventory i ON sp.inventory_id = i.inventory_id
    JOIN product_ingredient pi ON i.inventory_id = pi.inventory_id
    WHERE sp.supplier_id = supplier_id;
END //

DELIMITER ;
CALL ListProductsFromSupplier(1);

-- Functions
-- total products from supplier
DELIMITER //

CREATE FUNCTION GetTotalProductsFromSupplier(p_supplier_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE product_count INT;
    SELECT COUNT(*) INTO product_count
    FROM supplier_product
    WHERE supplier_id = p_supplier_id;  -- no changes needed here as it's correct
    RETURN product_count;
END //

DELIMITER ;

SELECT GetTotalProductsFromSupplier(1);  -- Retrieves the total number of products for supplier ID 1

-- total value from supplier
DELIMITER //

CREATE FUNCTION GetTotalProductValueFromSupplier(supplier_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_value DECIMAL(10,2);
    SELECT SUM(sp.price * i.quantity) INTO total_value  -- assuming quantity from inventory or other related table
    FROM supplier_product sp
    JOIN inventory i ON sp.inventory_id = i.inventory_id
    WHERE sp.supplier_id = supplier_id;
    RETURN total_value;
END //

DELIMITER ;

SELECT GetTotalProductValueFromSupplier(1);  -- Retrieves the total value of products for supplier ID 1
