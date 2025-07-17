CREATE TYPE status_enum AS ENUM ('pending','in_transit','delivered','cancelled');

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
INSERT INTO vehicles (vehicle_id, vehicle_type, capacity, status, created_at)
SELECT
    2000 + gs,
    (ARRAY[
        'Truck', 'Van', 'Mini Van', 'Cargo Bike', 'Box Truck',
        'Pickup', 'Refrigerated Truck', 'Scooter', 'Panel Van', 'Flatbed',
        'Semi-Trailer', 'Electric Van', 'SUV', 'Motorbike', 'Transit Van',
        'Forklift', 'Hybrid Van', 'Electric Cargo Bike', 'Compact Truck', 'Delivery Robot',
        'CNG Van', 'Double Trailer', 'Dump Truck', 'Tanker', 'Lowboy',
        'Step Deck', 'Concrete Mixer', 'Livestock Trailer', 'Gravel Truck', 'Dry Van'
    ])[gs],
    (RANDOM() * 1000 + 500)::INT,
    (ARRAY['active', 'maintenance', 'unavailable'])[FLOOR(RANDOM()*3)+1],
    NOW() - (INTERVAL '365 days' * RANDOM())
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
INSERT INTO drivers (driver_id, driver_name, driver_phone, vehicle_id, created_at)
SELECT
    660 + gs,  -- driver_id = 661–690
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

    2000 + gs AS vehicle_id,  -- vehicle_id = 2001–2030

    NOW() - (INTERVAL '365 days' * RANDOM()) AS created_at
FROM generate_series(1, 30) AS gs;

ALTER TABLE drivers ADD COLUMN priority_level VARCHAR(20);

UPDATE drivers
SET priority_level = (ARRAY['high', 'medium', 'low'])[FLOOR(RANDOM() * 3) + 1]
WHERE driver_id BETWEEN 661 AND 690;

SELECT * FROM drivers;

SELECT COUNT(driver_id) FROM drivers;

SELECT  MAX(driver_id) FROM drivers;
DELETE FROM drivers;
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
    status
)
SELECT
    (trunc(random() * 200) + 501)::INT AS customer_id,            -- 501–700
    (trunc(random() * 510) + 3001)::INT AS product_id,            -- 3001–3510
    (trunc(random() * 20) + 1)::INT AS shipment_quantity,         -- 1–20
    (trunc(random() * 60) + 101)::INT AS origin_warehouse_id,     -- 101–160
    (trunc(random() * 400) + 1)::INT AS destination_address_id,   -- 1–400
    (trunc(random() * 30) + 661)::INT AS driver_id,               -- 661–690
    (ARRAY['pending', 'in_transit', 'delivered', 'cancelled'])[floor(random() * 4 + 1)]::status_enum
FROM generate_series(1, 600);


DELETE FROM shipments;
-- რამდენი მომხმარებელია
SELECT COUNT(*), MIN(customer_id), MAX(customer_id) FROM customers;

-- რამდენი პროდუქტი
SELECT COUNT(*), MIN(product_id), MAX(product_id) FROM products;

SELECT COUNT(shipment_id) FROM shipments;

SELECT  MAX(shipment_id) FROM shipments;
SELECT * FROM shipments;

drop table shipments;
select status from shipments
group by status;
--გზავნილები/შეკვეთები 
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE DEFAULT CURRENT_DATE,
    delivery_date DATE,  -- მიტანის თარიღი (არ უნდა იყოს წარსულში)
    status status_enum DEFAULT 'pending',
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (customer_id, order_date, delivery_date, status, total_amount)
SELECT
    (TRUNC(RANDOM() * 200) + 501)::INT AS customer_id,
    CURRENT_DATE - (TRUNC(RANDOM() * 30))::INT AS order_date,  -- ბოლო 30 დღეში შეკვეთა
    CURRENT_DATE + (TRUNC(RANDOM() * 10) + 1)::INT AS delivery_date, -- 1–10 დღით გვიან
    (ARRAY['pending', 'in_transit', 'delivered', 'cancelled'])[FLOOR(RANDOM()*4)+1]::status_enum,
    ROUND((RANDOM() * 900 + 100)::NUMERIC, 2)  -- 100–1000 დოლარი
FROM generate_series(1, 200);


-- მარშრუტები
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    origin_address_id INT,
    destination_address_id INT,
    estimated_time INTERVAL,
    distance_km DECIMAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO routes (origin_address_id, destination_address_id, estimated_time, distance_km)
SELECT
    origin_id,
    destination_id,
    (trunc(random() * 10 + 1) || ' hours')::interval,
    ROUND((random() * 900 + 100)::numeric, 2)  -- 100 – 1000 კმ, ორი ათწილადი
FROM (
    SELECT DISTINCT
        (trunc(random() * 50 + 1))::int AS origin_id,
        (trunc(random() * 50 + 1))::int AS destination_id
    FROM generate_series(1, 1000)
) AS random_routes
WHERE origin_id <> destination_id
LIMIT 400;



select * from routes;
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
drop table vehicle_maintenance;
● ღირებულების გაანგარიშება (საწვავი, შრომა, შენახვა)



2. რთული შეზღუდვები 

○ უზრუნველყოს გზავნილის წონა არ აღემატებოდეს ტრანსპორტის ტევადობას 
drop FUNCTION check_vehicle_capacity;

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


შედეგი 4: ბიზნეს ლოგიკის განხორციელება 
შექმენით შემდეგი stored procedure/ფუნქციები: 

1. calculate_shipping_cost() 
○ შეყვანა: წარმოშობა, დანიშნულება, წონა, მომსახურების_ტიპი 
○ გამოყვანა: გამოანგარიშებული ღირებულება დისტანციის, წონისა და 
მომსახურების დონის მიხედვით 
○ მოიცავს საწვავის დანამატებსა და სეზონურ კორექტირებებს 
drop FUNCTION calculate_shipping_cost;

CREATE OR REPLACE FUNCTION calculate_shipping_cost(
    origin_id INT,
    destination_id INT,
    weight DECIMAL(10,2),
    service_type VARCHAR
)
RETURNS DECIMAL(10,2)
AS $$
DECLARE
    base_cost DECIMAL(10,2);
    distance_km DECIMAL(10,2);
    fuel_surcharge_rate DECIMAL := 0.05;  -- 5% საწვავის დანამატი
    seasonal_adjustment_rate DECIMAL := 0.10;  -- 10% სეზონური კორექტირება
    service_multiplier DECIMAL := 1.0;
BEGIN
    --  
    SELECT r.distance_km INTO distance_km
    FROM routes r
    WHERE r.origin_address_id = origin_id AND r.destination_address_id = destination_id;

    IF distance_km IS NULL THEN
        RAISE EXCEPTION 'Route not found between % and %', origin_id, destination_id;
    END IF;

    -- 
    CASE LOWER(service_type)
        WHEN 'standard' THEN service_multiplier := 1.0;
        WHEN 'express' THEN service_multiplier := 1.5;
        WHEN 'overnight' THEN service_multiplier := 2.0;
        ELSE
            RAISE EXCEPTION 'Invalid service type: %', service_type;
    END CASE;

    -- საბაზისო ღირებულება
    base_cost := (distance_km * 0.50) + (weight * 0.20);

    -- დანამატები
    base_cost := base_cost * (1 + fuel_surcharge_rate);
    base_cost := base_cost * (1 + seasonal_adjustment_rate);

    -- 
    base_cost := base_cost * service_multiplier;

    RETURN ROUND(base_cost, 2);
END;
$$ LANGUAGE plpgsql;



SELECT calculate_shipping_cost(2, 37, 10.5, 'express');
SELECT calculate_shipping_cost(2, 37, 12, 'standard');

SELECT calculate_shipping_cost(44, 19, 15, 'express');

select * from vehicle_maintenance;
-----------

2. assign_optimal_route() 

○ შეყვანა: გზავნილის_იდ, პრიორიტეტის_დონე 
○ ლოგიკა: იპოვეთ საუკეთესო ტრანსპორტი და მარშრუტი ტევადობის, მძღოლის 
ხელმისაწვდომობისა და მიწოდების დედლაინების გათვალისწინებით 

drop FUNCTION assign_optimal_route;

CREATE OR REPLACE FUNCTION assign_optimal_route(
    p_shipment_id INT,
    p_priority_level VARCHAR
)
RETURNS TEXT
AS $$
DECLARE
    product_id INT;
    quantity INT;
    weight_per_unit DECIMAL(10,2);
    origin_id INT;
    destination_id INT;
    total_weight DECIMAL(10,2);
    selected_driver_id INT;
    selected_vehicle_id INT;
    route_found BOOLEAN;
BEGIN
    -- shipment-ის დეტალები
    SELECT 
        s.product_id,
        s.shipment_quantity,
        s.origin_warehouse_id,
        s.destination_address_id,
        p.weight_per_unit
    INTO 
        product_id,
        quantity,
        origin_id,
        destination_id,
        weight_per_unit
    FROM shipments s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.shipment_id = p_shipment_id;

    -- თუ ვერ მოიძებნა shipment
    IF NOT FOUND THEN
        RETURN 'Shipment not found';
    END IF;

    -- ჯამური წონა
    total_weight := quantity * weight_per_unit;

    -- მძღოლი და მანქანა
    SELECT d.driver_id, v.vehicle_id
    INTO selected_driver_id, selected_vehicle_id
    FROM drivers d
    JOIN vehicles v ON v.vehicle_id = d.vehicle_id
    WHERE v.capacity >= total_weight
      AND v.status = 'active'
      AND NOT EXISTS (
          SELECT 1 FROM shipments s2
          WHERE s2.driver_id = d.driver_id
            AND s2.status IN ('pending', 'in_transit')
      )
    LIMIT 1;

    IF selected_driver_id IS NULL THEN
        RETURN 'No available driver/vehicle';
    END IF;

    -- მარშრუტის არსებობის შემოწმება
    SELECT EXISTS (
        SELECT 1 FROM routes
        WHERE origin_address_id = origin_id
          AND destination_address_id = destination_id
    ) INTO route_found;

    IF NOT route_found THEN
        RETURN 'No matching route found';
    END IF;

    -- განახლება
    UPDATE shipments
    SET driver_id = selected_driver_id,
        status = 'in_transit'
    WHERE shipment_id = p_shipment_id;

    RETURN format(
        'Shipment %s assigned to driver %s and vehicle %s',
        p_shipment_id, selected_driver_id, selected_vehicle_id
    );
END;
$$ LANGUAGE plpgsql;

SELECT assign_optimal_route(1205, 'express');

--------
SELECT * FROM drivers WHERE priority_level = 'high';
----
SELECT d.driver_id, d.driver_name, v.capacity,priority_level
FROM drivers d
JOIN vehicles v ON v.vehicle_id = d.vehicle_id
WHERE d.priority_level = 'high'
  AND v.status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM shipments s
    WHERE s.driver_id = d.driver_id
      AND s.status IN ('pending', 'in_transit')
  );

SELECT driver_id, driver_name, priority_level FROM drivers LIMIT 10;

SELECT v.vehicle_id, v.status FROM vehicles v WHERE v.status = 'active';
---
SELECT DISTINCT s.driver_id
FROM shipments s
WHERE s.status IN ('pending', 'in_transit');

----
SELECT d.driver_id, d.driver_name
FROM drivers d
WHERE NOT EXISTS (
    SELECT 1 FROM shipments s
    WHERE s.driver_id = d.driver_id
      AND s.status IN ('pending', 'in_transit')
);

-----
SELECT d.driver_id, d.driver_name, d.driver_phone, v.vehicle_id, v.capacity
FROM drivers d
JOIN vehicles v ON d.vehicle_id = v.vehicle_id
AND v.status = 'active';
---
select * from drivers;
SELECT * FROM shipments;
SELECT * FROM vehicles;

SELECT assign_optimal_route(663, 'delivered');

SELECT assign_optimal_route(1206, 'pending');




3. update_shipment_status() 
○ შეყვანა: ტრეკინგ_ნომერი, ახალი_სტატუსი, ლოკაცია 
○ მოიცავს ავტომატურ დროის ბეჭდვას და მომხმარებლის შეტყობინებებს 
4. generate_delivery_manifest() 
○ შეყვანა: მარშრუტის_იდ, თარიღი 
○ გამოყვანა: სრული მიწოდების სია ოპტიმიზირებული გაჩერებების 
თანმიმდევრობით

