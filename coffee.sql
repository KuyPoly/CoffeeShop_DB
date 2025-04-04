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
    product_name VARCHAR(20) NOT NULL,
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
-- Insert roles
INSERT INTO role (role_name, hour_salary) VALUES
('Manager', 25.00),
('Barista', 18.50),
('Cashier', 16.00);

-- Insert categories
INSERT INTO category (category_name, description) VALUES
('Coffee', 'Hot coffee drinks'),
('Tea', 'Various tea options'),
('Pastry', 'Baked goods'),
('Specialty', 'Seasonal specials');

-- Insert payment methods
INSERT INTO method (name, description) VALUES
('Cash', 'Physical currency'),
('Credit Card', 'Card payments'),
('Mobile Pay', 'Digital wallet payments');

-- Insert suppliers
INSERT INTO supplier (name, phone_number, address) VALUES
('Bean Supreme', '012121314', '123 Coffee Bean Lane'),
('Dairy Delight', '092929394', '456 Milk Road'),
('Sweet Treats Co', '096969798', '789 Sugar Street');

-- Insert employees
INSERT INTO employees (first_name, last_name, start_date, role_id, phone_number, address, manager_id) VALUES
('John', 'Smith', '2020-01-15', 1, '012434445', '123 Main St', NULL),
('Sarah', 'Johnson', '2021-03-01', 2, '097969594', '456 Oak Ave', 1),
('Mike', 'Chen', '2022-06-15', 3, '096234238', '789 Pine Rd', 1);

-- Insert products
INSERT INTO products (product_name, category_id, price) VALUES
('Espresso', 1, 3.50),
('Cappuccino', 1, 4.75),
('Latte', 1, 5.00),
('Matcha Tea', 2, 4.50),
('Croissant', 3, 3.25),
('Pumpkin Spice Latte', 4, 5.50);

-- Insert inventory
INSERT INTO inventory (name, quantity, restock_date, unit) VALUES
('Coffee Beans', 10000, '2023-07-01', 'grams'),
('Milk', 50, '2023-07-05', 'liters'),
('Sugar', 20000, '2023-07-10', 'grams'),
('Matcha Powder', 5000, '2023-07-08', 'grams'),
('Flour', 15000, '2023-07-03', 'grams');

-- Insert supplier products
INSERT INTO supplier_product (supplier_id, inventory_id, price, time) VALUES
(1, 1, 15.00, '02:00:00'),  -- Coffee beans
(2, 2, 2.50, '01:30:00'),   -- Milk
(3, 5, 8.00, '03:00:00'),   -- Flour
(3, 3, 4.00, '01:00:00');   -- Sugar

-- Insert product ingredients
INSERT INTO product_ingredient (product_id, inventory_id, quantity_used) VALUES
(1, 1, 7.00),   -- Espresso: 7g coffee beans
(2, 1, 7.00),   -- Cappuccino: 7g coffee beans
(2, 2, 0.15),   -- Cappuccino: 0.15L milk
(3, 1, 7.00),   -- Latte: 7g coffee beans
(3, 2, 0.2),    -- Latte: 0.2L milk
(4, 4, 5.00),   -- Matcha Tea: 5g matcha powder
(5, 5, 50.00),  -- Croissant: 50g flour
(6, 1, 7.00),   -- Pumpkin Spice Latte: 7g coffee beans
(6, 2, 0.2);    -- Pumpkin Spice Latte: 0.2L milk

-- Insert employee shifts
INSERT INTO employee_shift (employee_id, shift_date, shift_start, shift_end) VALUES
(1, '2023-07-01', '08:00:00', '16:00:00'),
(2, '2023-07-01', '07:00:00', '15:00:00'),
(3, '2023-07-01', '10:00:00', '18:00:00');

-- Insert orders
INSERT INTO orders (date, total, method_id, employee_id) VALUES
('2023-07-01', 12.25, 2, 3),
('2023-07-01', 8.75, 1, 3),
('2023-07-01', 5.50, 3, 2);

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 2, 2),  -- 2 Cappuccinos
(1, 5, 1),  -- 1 Croissant
(2, 1, 3),  -- 3 Espressos
(3, 6, 1);  -- 1 Pumpkin Spice Latte