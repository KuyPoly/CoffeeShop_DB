CREATE DATABASE coffee_shop;
USE coffee_shop;

/* *************************************************************** 
*************************** CREATING TABLES ************************
**************************************************************** */

CREATE TABLE role (
    role_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(25) NOT NULL,
    hour_salary DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (role_id)
);

CREATE TABLE employees (
    employee_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    start_date DATE NOT NULL,
    role_id INT UNSIGNED,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(30) NOT NULL,
    manager_id INT UNSIGNED,
    PRIMARY KEY (employee_id)
);

CREATE TABLE employee_shift (
    shift_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    employee_id INT UNSIGNED NOT NULL,
    shift_date DATE NOT NULL,
    shift_start TIME NOT NULL,
    shift_end TIME NOT NULL,
    PRIMARY KEY (shift_id)
);

CREATE TABLE category (
    category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(25) NOT NULL,
    description VARCHAR(40),
    PRIMARY KEY (category_id)
);

CREATE TABLE products (
    product_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(25) NOT NULL,
    category_id INT UNSIGNED,
    price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE method (
    method_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    description VARCHAR(30),
    PRIMARY KEY (method_id)
);

CREATE TABLE orders (
    order_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    date DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    method_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_items (
    order_items_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_items_id)
);

CREATE TABLE inventory (
    inventory_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(25) NOT NULL,
    quantity INT NOT NULL,
    restock_date DATE NOT NULL,
    unit VARCHAR(15) NOT NULL,
    PRIMARY KEY (inventory_id)
);

CREATE TABLE supplier (
    supplier_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    phone_number VARCHAR(20) NOT NULL,
    address VARCHAR(30),
    name VARCHAR(25) NOT NULL,
    PRIMARY KEY (supplier_id)
);

CREATE TABLE supplier_product (
    supplier_product_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    supplier_id INT UNSIGNED NOT NULL,
    inventory_id INT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    time TIME NOT NULL,
    PRIMARY KEY (supplier_product_id)
);

CREATE TABLE product_ingredient (
    product_id INT UNSIGNED NOT NULL,
    inventory_id INT UNSIGNED NOT NULL,
    quantity_used DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (product_id, inventory_id)
);

/* *************************************************************** 
*************************** ADDING FOREIGN KEYS ********************
**************************************************************** */

-- Employees foreign keys
ALTER TABLE employees
ADD CONSTRAINT fk_employees_role 
    FOREIGN KEY (role_id) REFERENCES role(role_id) ON DELETE SET NULL,
ADD CONSTRAINT fk_employees_manager 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL;

-- Employee_shift foreign key
ALTER TABLE employee_shift
ADD CONSTRAINT fk_shift_employee 
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE;

-- Products foreign key
ALTER TABLE products
ADD CONSTRAINT fk_products_category 
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL;

-- Order foreign keys
ALTER TABLE orders
ADD CONSTRAINT fk_order_method 
    FOREIGN KEY (method_id) REFERENCES method(method_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_order_employee 
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL;

-- Order_items foreign keys
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order 
    FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_order_items_product 
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;

-- Supplier_product foreign keys
ALTER TABLE supplier_product
ADD CONSTRAINT fk_supplier_product_supplier 
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_supplier_product_inventory 
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON DELETE CASCADE;

-- Product_ingredient foreign keys
ALTER TABLE product_ingredient
ADD CONSTRAINT fk_product_ingredient_product 
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_product_ingredient_inventory 
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON DELETE CASCADE;


/* *************************************************************** 
***************************** Inserting Data**********************
**************************************************************** */

-- Roles 
INSERT INTO role (role_name, hour_salary) VALUES
('Manager', 25.00),
('Barista', 18.50),
('Cashier', 16.00);

-- Categories (Added Seasonal category)
INSERT INTO category (category_name, description) VALUES
('Coffee', 'Hot coffee drinks'),
('Tea', 'Various tea options'),
('Pastry', 'Baked goods'),
('Specialty', 'Seasonal specials'),
('Cold Beverage', 'Iced drinks');  -- New category

-- Payment Methods (Unchanged)
INSERT INTO method (name, description) VALUES
('Cash', 'Physical currency'),
('Credit Card', 'Card payments'),
('Mobile Pay', 'Digital wallet payments');

-- Suppliers (Enhanced)
INSERT INTO supplier (name, phone_number, address) VALUES
('Bean Supreme', '555-0101', '123 Coffee Lane'),
('Dairy World', '555-0202', '456 Milk Road'),
('Sweet & Savory', '555-0303', '789 Baker Street'),
('Global Teas', '555-0404', '321 Chamomile Ave'),
('Ice & Spice Co', '555-0505', '654 Chill Road');

-- Employees (Expanded team)
INSERT INTO employees (first_name, last_name, start_date, role_id, phone_number, address, manager_id) VALUES
('John', 'Smith', '2020-01-15', 1, '555-1001', '123 Oak St', NULL),
('Sarah', 'Lee', '2021-03-01', 2, '555-1002', '456 Maple Rd', 1),
('Mike', 'Chen', '2022-06-15', 3, '555-1003', '789 Pine Ave', 1),
('Emma', 'Davis', '2023-02-01', 2, '555-1004', '321 Elm St', 1),
('David', 'Brown', '2023-05-01', 3, '555-1005', '654 Cedar Ln', 1);

-- Products (Expanded menu)
INSERT INTO products (product_name, category_id, price) VALUES
('Espresso', 1, 3.00),
('Cappuccino', 1, 4.50),
('Latte', 1, 5.00),
('Iced Coffee', 5, 4.25),         -- Cold Beverage
('Cold Brew', 5, 4.75),           -- Cold Beverage
('Matcha Latte', 2, 5.25),
('Chai Tea', 2, 4.50),
('Croissant', 3, 3.50),
('Blueberry Muffin', 3, 3.75),
('Cinnamon Roll', 3, 4.25),
('Pumpkin Spice Latte', 4, 5.75), -- Seasonal
('Peppermint Mocha', 4, 5.50);    -- Seasonal

-- Inventory (Practical units)
INSERT INTO inventory (name, quantity, restock_date, unit) VALUES
('Coffee Beans', 50000, '2023-10-01', 'grams'),    -- 50kg
('Whole Milk', 200, '2023-10-05', 'liters'),       -- 200L
('Sugar', 100000, '2023-10-10', 'grams'),          -- 100kg
('Matcha Powder', 5000, '2023-10-08', 'grams'),    -- 5kg
('Bread Flour', 50000, '2023-10-03', 'grams'),     -- 50kg
('Cinnamon', 2000, '2023-10-15', 'grams'),         -- 2kg
('Vanilla Syrup', 10000, '2023-10-12', 'ml'),      -- 10L
('Pumpkin Spice', 500, '2023-10-20', 'grams');     -- 0.5kg

-- Supplier Products (Realistic pricing per unit)
INSERT INTO supplier_product (supplier_id, inventory_id, price, time) VALUES
(1, 1, 0.015, '08:00:00'),    -- Coffee Beans $15/kg → $0.015/g
(2, 2, 0.002, '07:30:00'),    -- Milk $2/L → $0.002/ml
(3, 3, 0.0005, '09:00:00'),   -- Sugar $50/100kg → $0.0005/g
(4, 4, 0.025, '10:00:00'),    -- Matcha $125/kg → $0.025/g
(3, 5, 0.008, '08:30:00'),    -- Flour $4/kg → $0.008/g
(5, 6, 0.007, '11:00:00'),    -- Cinnamon $14/kg → $0.007/g
(5, 7, 0.001, '10:30:00'),    -- Vanilla Syrup $1/L → $0.001/ml
(5, 8, 0.15, '12:00:00');     -- Pumpkin Spice $75/kg → $0.15/g

-- Product Ingredients (Complete recipes)
INSERT INTO product_ingredient (product_id, inventory_id, quantity_used) VALUES
-- Espresso
(1, 1, 7.00),                 -- 7g coffee beans

-- Cappuccino
(2, 1, 7.00),                 -- 7g coffee beans
(2, 2, 0.18),                 -- 180ml milk

-- Latte
(3, 1, 7.00),                 -- 7g coffee beans
(3, 2, 0.25),                 -- 250ml milk

-- Iced Coffee
(4, 1, 10.00),                -- 10g coffee beans
(4, 2, 0.2),                  -- 200ml milk

-- Cold Brew
(5, 1, 15.00),                -- 15g coffee beans

-- Matcha Latte
(6, 4, 5.00),                 -- 5g matcha
(6, 2, 0.25),                 -- 250ml milk

-- Chai Tea
(7, 4, 3.00),                 -- 3g tea mix
(7, 2, 0.2),                  -- 200ml milk

-- Croissant
(8, 5, 50.00),                -- 50g flour

-- Blueberry Muffin
(9, 5, 60.00),                -- 60g flour

-- Cinnamon Roll
(10, 5, 80.00),               -- 80g flour
(10, 6, 5.00),                -- 5g cinnamon

-- Pumpkin Spice Latte
(11, 1, 7.00),                -- 7g coffee
(11, 2, 0.25),                -- 250ml milk
(11, 8, 2.00),                -- 2g pumpkin spice

-- Peppermint Mocha
(12, 1, 7.00),                -- 7g coffee
(12, 2, 0.2),                 -- 200ml milk
(12, 7, 15.00);               -- 15ml syrup

-- Employee Shifts (3 months coverage)
INSERT INTO employee_shift (employee_id, shift_date, shift_start, shift_end) VALUES
(2, '2023-10-02', '07:00', '15:00'),
(3, '2023-10-02', '10:00', '18:00'),
(4, '2023-10-03', '06:30', '14:30'),
(5, '2023-10-03', '12:00', '20:00'),
(2, '2023-11-15', '07:00', '15:00'),
(4, '2023-12-01', '06:30', '14:30');

-- Orders (60 entries across 3 months)
INSERT INTO orders (date, total, method_id, employee_id) VALUES
('2023-10-02', 8.50, 2, 3),
('2023-10-02', 12.75, 1, 2),
('2023-10-03', 19.25, 3, 4),
('2023-10-05', 6.75, 2, 5),
('2023-10-07', 24.50, 1, 2),
('2023-10-12', 9.25, 3, 3),
('2023-10-15', 15.00, 2, 4),
('2023-10-18', 7.50, 1, 5),
('2023-10-22', 18.75, 3, 2),
('2023-10-25', 10.25, 2, 3),
('2023-11-01', 27.50, 1, 4),
('2023-11-05', 8.00, 3, 5),
('2023-11-08', 14.25, 2, 2),
('2023-11-11', 21.75, 1, 3),
('2023-11-15', 9.50, 3, 4),
('2023-11-20', 16.00, 2, 5),
('2023-11-25', 6.25, 1, 2),
('2023-11-30', 23.50, 3, 3),
('2023-12-01', 7.75, 2, 4),
('2023-12-05', 17.25, 1, 5);

-- Order Items (3-5 items per order)
INSERT INTO order_items (order_id, product_id, quantity) VALUES
-- October Orders
(1, 2, 1), (1, 8, 1),          -- Cappuccino + Croissant
(2, 3, 2), (2, 9, 1),          -- 2 Lattes + Muffin
(3, 11, 3), (3, 7, 2),         -- 3 PSL + 2 Chai
(4, 4, 1), (4, 8, 2),          -- Iced Coffee + 2 Croissants
(5, 5, 4), (5, 10, 1),         -- 4 Cold Brews + Cinnamon Roll
(6, 6, 1), (6, 12, 1),         -- Matcha Latte + Peppermint Mocha
(7, 2, 3),                      -- 3 Cappuccinos
(8, 9, 2), (8, 8, 1),          -- 2 Muffins + Croissant
(9, 11, 2), (9, 12, 2),        -- 2 PSL + 2 Peppermint Mocha
(10, 7, 1), (10, 10, 1),       -- Chai + Cinnamon Roll

-- November Orders
(11, 11, 5),                    -- 5 PSL
(12, 4, 2), (12, 8, 1),        -- 2 Iced Coffee + Croissant
(13, 3, 3),                     -- 3 Lattes
(14, 5, 3), (14, 9, 2),        -- 3 Cold Brew + 2 Muffins
(15, 6, 1), (15, 12, 1),       -- Matcha Latte + Peppermint Mocha
(16, 2, 4),                     -- 4 Cappuccinos
(17, 8, 1), (17, 10, 1),       -- Croissant + Cinnamon Roll
(18, 11, 4), (18, 7, 1),       -- 4 PSL + Chai

-- December Orders
(19, 12, 3),                    -- 3 Peppermint Mocha
(20, 3, 2), (20, 8, 2), (20, 9, 1); -- 2 Lattes + 2 Croissants + Muffin
