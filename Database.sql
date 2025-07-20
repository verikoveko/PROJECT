-- GlobalShip Logistics - SQL Project

-- 1. ENUM TYPES
CREATE TYPE status_enum AS ENUM ('pending', 'in_transit', 'delivered', 'cancelled');

-- 2. CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 100 customers with IDs 1–100
INSERT INTO customers (customer_id, first_name, last_name, email, phone, created_at)
SELECT 
    gs AS customer_id,
    'Name' || gs, 'Surname' || gs, 'user' || gs || '@example.com',
    '+9955' || LPAD((TRUNC(RANDOM()*1000000))::TEXT, 6, '0'),
    NOW() - (INTERVAL '1 day' * (RANDOM() * 365))
FROM generate_series(1, 100) AS gs;

SELECT * FROM customers;
-- 3. SUPPLIERS
CREATE TABLE suppliers (
    supplier_id int PRIMARY KEY,
    supplier_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert suppliers with IDs 101–150
INSERT INTO suppliers (supplier_id, supplier_name, email, phone, created_at)
SELECT 
    100 + gs AS supplier_id,
    'Supplier' || (100 + gs),
    'supplier' || (100 + gs) || '@example.com',
    '+9955' || LPAD((TRUNC(RANDOM()*1000000))::TEXT, 6, '0'),
    NOW() - (INTERVAL '1 day' * (RANDOM() * 365))
FROM generate_series(1, 50) AS gs;

SELECT * FROM suppliers;

-- 4. PRODUCTS
CREATE TABLE products (
    product_id int PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(supplier_id),
    product_name VARCHAR(100),
    unit_price DECIMAL(10,2),
    weight_per_unit DECIMAL(10,2),
    category_name TEXT,
    quantity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 500 products with IDs 201–700
INSERT INTO products (product_id, supplier_id, product_name, unit_price, weight_per_unit, category_name, quantity, created_at)
SELECT 
    200 + gs AS product_id,
    (100 + (RANDOM() * 49 + 1)::INT) AS supplier_id,
    'Product ' || (200 + gs), 
    ROUND((RANDOM() * 900 + 100)::numeric, 2),
    ROUND((RANDOM() * 10 + 1)::numeric, 2),
    (ARRAY['Computers', 'Televisions', 'Accessories'])[FLOOR(RANDOM()*3)+1],
    (RANDOM() * 100)::INT,
    CURRENT_TIMESTAMP
FROM generate_series(1, 500) AS gs;

SELECT * FROM products;

-- 5. ADDRESSES
CREATE TABLE addresses (
    address_id INT PRIMARY KEY,
    country VARCHAR(50),
    city VARCHAR(50),
    street VARCHAR(100),
    postal_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 400 addresses with IDs 1001–1400
INSERT INTO addresses (address_id, country, city, street, postal_code, created_at)
SELECT 
    1000 + gs AS address_id,
    'USA', 
    (ARRAY['New York','Chicago','Houston','Seattle','Los Angeles'])[FLOOR(RANDOM()*5)+1],
    (TRUNC(RANDOM()*9999)::INT || ' Main St'),
    LPAD((TRUNC(RANDOM()*90000 + 10000))::TEXT, 5, '0'),
    NOW() - (INTERVAL '1 day' * (RANDOM() * 365))
FROM generate_series(1, 400) AS gs;

SELECT * FROM addresses;

-- 6. WAREHOUSES
CREATE TABLE warehouses (
    warehouse_address_id INT PRIMARY KEY REFERENCES addresses(address_id),
    warehouse_city VARCHAR(50),
    warehouse_street VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 60 warehouses
INSERT INTO warehouses (warehouse_address_id, warehouse_city, warehouse_street, created_at)
SELECT 
    address_id, city, street, CURRENT_TIMESTAMP
FROM addresses
LIMIT 60;

SELECT * FROM warehouses;

- 7. VEHICLES
CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(50),
    capacity DECIMAL(10,2),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 150 vehicles with IDs 1401–1550

INSERT INTO vehicles (vehicle_id, vehicle_type, capacity, status, created_at)
SELECT 
    1400 + gs AS vehicle_id,
    (ARRAY['Truck','Van'])[FLOOR(RANDOM()*2)+1],
    ROUND((RANDOM() * 900 + 100)::numeric, 2),
    (ARRAY['active','maintenance','unavailable'])[FLOOR(RANDOM()*3)+1],
    CURRENT_TIMESTAMP
FROM generate_series(1, 150) AS gs;

SELECT * FROM vehicles;

-- 8. DRIVERS
CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(100),
    driver_phone VARCHAR(20),
    priority_level VARCHAR(20),
    vehicle_id INT REFERENCES vehicles(vehicle_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 200 drivers with IDs 1701–1900
INSERT INTO drivers (driver_id, driver_name, driver_phone, priority_level, vehicle_id, created_at)
SELECT 
    1700 + gs AS driver_id,
    'Driver ' || (1700 + gs),
    '+9955' || LPAD((TRUNC(RANDOM()*1000000))::TEXT, 6, '0'),
    (ARRAY['high', 'medium', 'low'])[FLOOR(RANDOM()*3)+1],
    1401 + ((gs - 1) % 150),
    CURRENT_TIMESTAMP
FROM generate_series(1, 200) AS gs;

SELECT * FROM drivers;


-- 9. ROUTES
CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    origin_address_id INT REFERENCES addresses(address_id),
    destination_address_id INT REFERENCES addresses(address_id),
    estimated_time INTERVAL,
    distance_km DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 400 routes with IDs 3001–3400 using distinct addresses
INSERT INTO routes (route_id, origin_address_id, destination_address_id, estimated_time, distance_km, created_at)
SELECT 
    4000 + gs AS route_id,
    w.warehouse_address_id AS origin_address_id,
    a.address_id AS destination_address_id,
    (TRUNC(RANDOM() * 8 + 2) || ' hours')::interval,
    ROUND((RANDOM()*1000 + 100)::numeric, 2),
    CURRENT_TIMESTAMP
FROM generate_series(1, 100) AS gs
JOIN warehouses w ON w.warehouse_address_id = 1000 + gs
JOIN addresses a ON a.address_id = 1200 + gs;

SELECT * FROM routes;
------
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    shipment_quantity INT NOT NULL,
    origin_warehouse_id INT REFERENCES warehouses(warehouse_address_id),
    destination_address_id INT REFERENCES addresses(address_id),
    driver_id INT REFERENCES drivers(driver_id),
    shipment_status status_enum DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_delivery_date DATE,
    actual_delivery_date DATE
);
-- Insert 1000 shipments with unique driver_id და სხვადასხვა სტატუსით

INSERT INTO shipments (
    shipment_id, product_id, shipment_quantity, origin_warehouse_id,
    destination_address_id, driver_id, shipment_status,
    created_at, expected_delivery_date
)
SELECT 
    4999 + gs AS shipment_id,
    (201 + (gs % 500)) AS product_id,
    (1 + (gs % 20)) AS shipment_quantity,
    w.warehouse_address_id AS origin_warehouse_id,
    a.address_id AS destination_address_id,
    d.driver_id,
    (ARRAY['pending','in_transit','delivered','cancelled'])[(gs % 4) + 1]::status_enum AS shipment_status,
    NOW() - (INTERVAL '1 day' * (RANDOM() * 90)),
    CURRENT_DATE + (ROUND(RANDOM() * 30)::INT)
FROM generate_series(1, 1000) AS gs
JOIN warehouses w ON w.warehouse_address_id = 1000 + ((gs - 1) % 60)
JOIN addresses a ON a.address_id = 1100 + ((gs - 1) % 300)
JOIN drivers d ON d.driver_id = 1701 + ((gs - 1) % 200)
WHERE w.warehouse_address_id <> a.address_id;

SELECT * FROM shipments;
