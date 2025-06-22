CREATE TYPE status_enum AS ENUM ('pending','in_transit','delivered','cancelled');
DROP TYPE status_enum;
-- მომხმარებლები (კომპანიები და ინდივიდუალები)

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (first_name, last_name, email, phone, created_at)
SELECT
    'FirstName' || gs,
    'LastName' || gs,
    'customer' || gs || '@example.com',
    '555-' || lpad((gs % 10000)::text, 4, '0'),
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 200) AS gs;


select * FROM customers;

select  MAX(customer_id) FROM customers;
 
SELECT  COUNT(customer_id) FROM customers;

-- მომწოდებლები/გამყიდველები

CREATE TABLE  suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO suppliers (suppliers_name, email, phone, created_at)
SELECT
    'Supplier ' || gs AS suppliers_name,
    'supplier' || gs || '@example.com' AS email,
    '555-' || lpad((gs % 1000)::text, 4, '0') AS phone,
    NOW() - (random() * INTERVAL '365 days') AS created_at  -- random date in past year
FROM generate_series(1, 500) AS gs;


SELECT * FROM suppliers;
-- პროდუქტები/ინვენტარი

CREATE TABLE  products(
    product_id SERIAL PRIMARY KEY,
    suppliers_id INTEGER REFERENCES suppliers(suppliers_id),
    product_name VARCHAR(50),
    unit_price DECIMAL(10,2),
    quantity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE products
ADD COLUMN category_name TEXT;



ALTER TABLE products
ADD COLUMN weight_per_unit DECIMAL(10,2);

INSERT INTO products (suppliers_id, product_name, unit_price, quantity, created_at, category_name, weight_per_unit)
SELECT
    (RANDOM()*9 + 1)::INT, -- suppliers_id 1–10
    p.product_name,
    p.unit_price,
    (RANDOM()*100 + 1)::INT,
    CURRENT_TIMESTAMP,
    p.category_name,
    p.weight_per_unit
FROM (
    VALUES
        -- Televisions
        ('Samsung 55" QLED TV', 899.99, 'Televisions', 14.5),
        ('LG 65" OLED TV', 1299.99, 'Televisions', 17.2),
        ('Sony 50" 4K LED TV', 749.00, 'Televisions', 13.1),
        ('TCL 43" Roku TV', 349.00, 'Televisions', 10.5),
        ('Hisense 65" ULED', 699.99, 'Televisions', 16.7),
        ('Vizio 70" Smart TV', 799.00, 'Televisions', 18.0),
        ('Panasonic 40" LED', 459.00, 'Televisions', 11.3),
        ('Philips 58" UHD TV', 649.00, 'Televisions', 15.6),
        ('Sharp 32" Smart TV', 229.00, 'Televisions', 8.9),
        ('Insignia 55" Fire TV', 499.00, 'Televisions', 13.9),

        -- Accessories
        ('Logitech Wireless Mouse', 29.99, 'Accessories', 0.2),
        ('Dell Keyboard', 49.99, 'Accessories', 0.9),
        ('HP Laptop Bag', 39.99, 'Accessories', 1.1),
        ('USB-C Cable 1m', 9.99, 'Accessories', 0.1),
        ('HDMI Cable 2m', 12.99, 'Accessories', 0.15),
        ('Portable Charger 10000mAh', 24.99, 'Accessories', 0.5),
        ('Gaming Mousepad XL', 19.99, 'Accessories', 0.3),
        ('Wireless Earbuds', 59.99, 'Accessories', 0.15),
        ('External Hard Drive 1TB', 79.99, 'Accessories', 0.4),
        ('Webcam Full HD', 69.99, 'Accessories', 0.25),

        -- Computers
        ('Dell Inspiron 15 Laptop', 649.99, 'Computers', 2.3),
        ('MacBook Air M2', 999.99, 'Computers', 1.2),
        ('HP Pavilion Desktop', 749.99, 'Computers', 5.1),
        ('Lenovo ThinkPad E15', 899.00, 'Computers', 2.0),
        ('ASUS VivoBook 14', 599.00, 'Computers', 1.9),
        ('Acer Aspire 5', 549.00, 'Computers', 2.1),
        ('MSI Gaming Laptop', 1199.99, 'Computers', 2.7),
        ('Mac Mini M2', 699.00, 'Computers', 1.3),
        ('Intel NUC Mini PC', 499.00, 'Computers', 1.0),
        ('Raspberry Pi 4 Kit', 129.99, 'Computers', 0.6)
) AS p(product_name, unit_price, category_name, weight_per_unit)
CROSS JOIN generate_series(1, 17); -- 30 პროდუქტი × 17 = 510 ჩანაწერი

SELECT * FROM products;
select  MAX(product_id) FROM products;

SELECT category_name FROM products
GROUP BY category_name;



-- ტრანსპორტი (სატვირთო, თვითმფრინავები, გემები)
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_type VARCHAR(50), 
    capacity INT,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- 30 მანქანის რეალური ჩანაწერის ჩასმა
INSERT INTO vehicles (vehicle_type, capacity, status, created_at)
SELECT
    (ARRAY[
        'Truck', 'Van', 'Mini Van', 'Cargo Bike', 'Box Truck',
        'Pickup', 'Refrigerated Truck', 'Scooter', 'Panel Van', 'Flatbed',
        'Semi-Trailer', 'Electric Van', 'SUV', 'Motorbike', 'Transit Van',
        'Forklift', 'Hybrid Van', 'Electric Cargo Bike', 'Compact Truck', 'Delivery Robot',
        'CNG Van', 'Double Trailer', 'Dump Truck', 'Tanker', 'Lowboy',
        'Step Deck', 'Concrete Mixer', 'Livestock Trailer', 'Gravel Truck', 'Dry Van'
    ])[gs] AS vehicle_type,
    (RANDOM() * 1000 + 500)::INT AS capacity, -- ტევადობა: 500–1500 კგ
    (ARRAY['active', 'maintenance', 'unavailable'])[FLOOR(RANDOM()*3)+1] AS status,
    NOW() - (INTERVAL '365 days' * RANDOM()) AS created_at
FROM generate_series(1, 30) AS gs;


SELECT * FROM vehicles;

SELECT COUNT (vehicle_id) FROM vehicles;
DELETE FROM vehicles;

-- მძღოლები/ოპერატორები
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    driver_name VARCHAR(50),
    driver_phone VARCHAR(50),
    vehicle_id INT REFERENCES vehicles(vehicle_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 30 მძღოლის ჩასმა 
INSERT INTO drivers (driver_name, driver_phone, vehicle_id, created_at)
SELECT
    (ARRAY[
        'Giorgi', 'Nika', 'Irakli', 'Lasha', 'Tornike',
        'Ana', 'Nino', 'Mariam', 'Tatia', 'Saba',
        'Elene', 'Luka', 'Dato', 'Sandro', 'Keti',
        'Natia', 'Beka', 'Sopho', 'Salome', 'Alex',
        'Tamuna', 'Goga', 'Zura', 'Ilia', 'Natia',
        'Nana', 'Gvanca', 'Gela', 'Lali', 'Shako'
    ])[gs] || ' ' ||
    (ARRAY[
        'Beridze', 'Kapanadze', 'Kiknadze', 'Chkheidze', 'Lomidze',
        'Tugushi', 'Khutsishvili', 'Abuladze', 'Maisuradze', 'Gogoladze',
        'Tsereteli', 'Gelashvili', 'Topuria', 'Megrelishvili', 'Khurtsidze',
        'Kobakhidze', 'Kavtaradze', 'Japaridze', 'Kalandadze', 'Melikidze',
        'Tabidze', 'Makharadze', 'Bregvadze', 'Kavlashvili', 'Oniani',
        'Gvazava', 'Lortkipanidze', 'Janelidze', 'Ghudushauri', 'Sharashenidze'
    ])[gs] AS driver_name,
    
    '+9955' || LPAD((TRUNC(RANDOM()*1000000))::TEXT, 6, '0') AS driver_phone,
    gs + 40 AS vehicle_id,  -- ანუ 41-დან 70-მდე
    NOW() - (INTERVAL '365 days' * RANDOM()) AS created_at
FROM generate_series(1, 30) AS gs;


SELECT * FROM drivers;

SELECT COUNT(driver_id) FROM drivers;

SELECT  MAX(driver_id) FROM drivers;

-- გზავნილები/შეკვეთები
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    shipment_quantity INT,
    origin_warehouse_id INT REFERENCES warehouses(warehouse_address_id),
    destination_address_id INT REFERENCES addresses(address_id),
    driver_id INT REFERENCES drivers(driver_id),
    status status_enum,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO shipments (
    customer_id,
    product_id,
    shipment_quantity,
    origin_warehouse_id,
    destination_address_id,
    driver_id,
    status,
    created_at
)
SELECT
    (SELECT customer_id FROM customers ORDER BY RANDOM() LIMIT 1),
    (SELECT product_id FROM products ORDER BY RANDOM() LIMIT 1),
    (RANDOM() * 10 + 1)::INT,                        -- shipment_quantity
    (SELECT warehouse_address_id FROM warehouses ORDER BY RANDOM() LIMIT 1),
    (SELECT address_id FROM addresses ORDER BY RANDOM() LIMIT 1),
    (SELECT driver_id FROM drivers ORDER BY RANDOM() LIMIT 1),
    (ARRAY['pending','in_transit','delivered','cancelled'])[FLOOR(RANDOM()*4)+1]::status_enum,
    NOW() - (INTERVAL '30 days' * RANDOM())
FROM generate_series(1, 600);

-- რამდენი მომხმარებელია
SELECT COUNT(*), MIN(customer_id), MAX(customer_id) FROM customers;

-- რამდენი პროდუქტი
SELECT COUNT(*), MIN(product_id), MAX(product_id) FROM products;


SELECT * FROM shipments;


-- მარშრუტები
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    origin_address_id INT,
    destination_address_id INT,
    estimated_time INTERVAL,
    distance_km DECIMAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- მისამართები/ლოკაციები
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    country VARCHAR(50),
    city VARCHAR(50),
    street VARCHAR(50),
    postal_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--400 მისამართის ჩასმა
INSERT INTO addresses (country, city, street, postal_code, created_at)
SELECT
    'United States',
    (ARRAY[
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
        'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
        'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte',
        'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Washington'
    ])[FLOOR(RANDOM()*20)+1] AS city,
    
    (TRUNC(RANDOM()*9999 + 1))::INT || ' ' ||
    (ARRAY[
        'Main St', 'Broadway', 'Elm St', 'Maple Ave', 'Oak St',
        'Pine St', 'Cedar St', '2nd St', '3rd Ave', 'Park Ave',
        'Washington Blvd', 'Lakeview Dr', 'Hillcrest Rd', 'Sunset Blvd', 'Madison Ave'
    ])[FLOOR(RANDOM()*15)+1] AS street,
    
    LPAD((TRUNC(RANDOM()*90000 + 10000))::TEXT, 5, '0') AS postal_code,
    
    NOW() - (INTERVAL '365 days' * RANDOM()) AS created_at
FROM generate_series(1, 400);

SELECT * FROM addresses;
SELECT MAX(address_id) FROM addresses;


CREATE TABLE warehouses (
    warehouse_address_id INT PRIMARY KEY,
    warehouse_city VARCHAR(50),
    warehouse_street VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO warehouses (warehouse_address_id, warehouse_city, warehouse_street, created_at)
SELECT
    gs + 100,  -- 101-დან 160-მდე IDs
    (ARRAY[
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
        'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
        'Austin', 'Jacksonville', 'Columbus', 'Charlotte', 'Denver',
        'Washington', 'Boston', 'El Paso', 'Nashville', 'Detroit'
    ])[FLOOR(RANDOM()*20)+1],
    (TRUNC(RANDOM()*9999 + 1))::TEXT || ' ' ||
    (ARRAY[
        'Main St', 'Broadway', 'Elm St', 'Maple Ave', 'Oak St',
        'Pine St', '2nd St', '3rd Ave', 'Sunset Blvd', 'Madison Ave'
    ])[FLOOR(RANDOM()*10)+1],
    NOW() - (INTERVAL '365 days' * RANDOM())
FROM generate_series(1, 60) AS gs;

SELECT * FROM warehouses;
SELECT MAX(warehouse_address_id) FROM warehouses;

DROP TABLE warehouse;
ძირითადი relationship მოდელირებისთვის: 

● მრავალ-გაჩერებიანი მარშრუტები სხვადასხვა ტრანსპორტით 

● საწყობის ინვენტარის ტრეკინგი 
● მძღოლების დავალებები/ტასკები და გრაფიკები 
● გზავნილის სტატუსის ტრეკინგი (მოლოდინი → ტრანზიტში → მიწოდებული) 

CREATE TYPE status_enum AS ENUM ('pending','in_transit','delivered','cancelled');


● ტრანსპორტის მოვლის გრაფიკები 

CREATE TABLE vehicle_maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(vehicle_id),
    description TEXT,
    maintenance_date DATE,
    cost DECIMAL(10,2)
);
● ღირებულების გაანგარიშება (საწვავი, შრომა, შენახვა)



2. რთული შეზღუდვები 

○ უზრუნველყოს გზავნილის წონა არ აღემატებოდეს ტრანსპორტის ტევადობას 

CREATE OR REPLACE FUNCTION check_vehicle_capacity()
RETURNS TRIGGER AS $$
DECLARE
    total_weight DECIMAL(10, 2);
    vehicle_capacity INT;
BEGIN
    -- 1. calculate total shipment weight
    SELECT SUM(p.weight_per_unit * s.shipment_quantity) as total_weight
    FROM shipments s
    JOIN products p ON s.product_id = p.product_id;
  
    -- 2. get vehicle capacity
    SELECT v.capacity
    INSERT INTO vehicle_capacity
    FROM shipments s
    JOIN drivers d ON s.driver_id = d.driver_id
    JOIN vehicles v ON d.vehicle_id = v.vehicle_id
    WHERE s.shipment_id = NEW.shipment_id;

    -- 3. compare
    IF total_weight > vehicle_capacity THEN
        RAISE EXCEPTION 'Shipment exceeds vehicle capacity';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


○ ვალიდაცია მიწოდების თარიღების მიხედვით ანუ ვერ შეუკვეთოს წინა თარიღით 
(ფუნქცია) 
ALTER TABLE orders ADD COLUMN delivery_date DATE;

CREATE OR REPLACE FUNCTION validate_delivery_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.delivery_date < CURRENT_DATE THEN
        RAISE EXCEPTION 'Delivery date cannot be in the past';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_delivery_date
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION validate_delivery_date();

○ ბიზნეს წესების განხორციელება (მძღოლები არ შეიძლება ერთდროულად 
რამდენიმე მარშრუტზე იყვნენ დანიშნულნი) 
DROP TRIGGER  trg_validate_delivery_date;