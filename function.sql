

შექმენით შემდეგი stored procedure/ფუნქციები: 

--- calculate_shipping_cost() 
○ შეყვანა: წარმოშობა, დანიშნულება, წონა, მომსახურების_ტიპი 
○ გამოყვანა: გამოანგარიშებული ღირებულება დისტანციის, წონისა და 
მომსახურების დონის მიხედვით 
○ მოიცავს საწვავის დანამატებსა და სეზონურ კორექტირებებს 

CREATE OR REPLACE FUNCTION calculate_shipping_cost(
    p_origin INT,
    p_destination INT,
    p_weight DECIMAL,
    p_service_level VARCHAR
)
RETURNS DECIMAL AS $$
DECLARE
    base_distance DECIMAL;
    fuel_surcharge DECIMAL := 1.15; -- 15% surcharge
    seasonal_multiplier DECIMAL := CASE
        WHEN EXTRACT(MONTH FROM CURRENT_DATE) IN (12, 1, 2) THEN 2.5 -- Winter
        WHEN EXTRACT(MONTH FROM CURRENT_DATE) IN (6, 7, 8) THEN 1.5 -- Summer
        ELSE 4.0
    END;
    service_multiplier DECIMAL := CASE
        WHEN p_service_level = 'standard' THEN 3.0
        WHEN p_service_level = 'express' THEN 5.5
        WHEN p_service_level = 'overnight' THEN 6.0
        ELSE 18.0
    END;
BEGIN
    SELECT distance_km INTO base_distance
    FROM routes
    WHERE origin_address_id = p_origin AND destination_address_id = p_destination
    LIMIT 1;

    IF base_distance IS NULL THEN
        RETURN -1;
    END IF;

    RETURN ROUND((base_distance * 0.5 + p_weight * 0.75) * fuel_surcharge * seasonal_multiplier * service_multiplier, 2);
END;
$$ LANGUAGE plpgsql;
drop FUNCTION calculate_shipping_cost;
--Test

SELECT calculate_shipping_cost(1001, 1201, 10.5, 'standard')

SELECT calculate_shipping_cost(1001, 1201, 9.5, 'express')

SELECT * FROM routes WHERE origin_address_id = 1001 AND destination_address_id = 1201;

select * from routes;

-- update_shipment_status() 

○ შეყვანა: ტრეკინგ_ნომერი, ახალი_სტატუსი, ლოკაცია 
○ მოიცავს ავტომატურ დროის ბეჭდვას და მომხმარებლის შეტყობინებებს 

CREATE OR REPLACE FUNCTION update_shipment_status(
    p_shipment_id INT,
    p_new_status status_enum,
    p_location INT
)
RETURNS TEXT AS $$
BEGIN
    UPDATE shipments
    SET shipment_status = p_new_status,
        actual_delivery_date = CASE
            WHEN p_new_status = 'delivered' THEN CURRENT_DATE
            ELSE actual_delivery_date
        END
    WHERE shipment_id = p_shipment_id;

    RETURN 'Status updated for shipment ' || p_shipment_id || ' to ' || p_new_status || ' at location ' || p_location;
END;
$$ LANGUAGE plpgsql;

-- generate_delivery_manifest() 
○ შეყვანა: მარშრუტის_იდ, თარიღი 
○ გამოყვანა: სრული მიწოდების სია ოპტიმიზირებული გაჩერებების 
თანმიმდევრობით
CREATE OR REPLACE FUNCTION generate_delivery_manifest(
    p_route_id INT,
    p_date DATE
)
RETURNS TABLE (
    shipment_id INT,
    destination_address_id INT,
    driver_id INT,
    expected_delivery_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.shipment_id,
        s.destination_address_id,
        s.driver_id,
        s.expected_delivery_date
    FROM shipments s
    JOIN routes r ON s.origin_warehouse_id = r.origin_address_id
        AND s.destination_address_id = r.destination_address_id
    WHERE r.route_id = p_route_id
      AND s.expected_delivery_date = p_date
    ORDER BY s.expected_delivery_date;
END;
$$ LANGUAGE plpgsql;

-- assign_optimal_route() 
○ შეყვანა: გზავნილის_იდ, პრიორიტეტის_დონე 
○ ლოგიკა: იპოვეთ საუკეთესო ტრანსპორტი და მარშრუტი ტევადობის, მძღოლის 
ხელმისაწვდომობისა და მიწოდების დედლაინების გათვალისწინებით 

CREATE OR REPLACE FUNCTION assign_optimal_route(
    p_shipment_id INT,
    p_priority_level VARCHAR
)
RETURNS TEXT AS $$
DECLARE
    shipment_rec RECORD;
    chosen_driver_id INT;
    chosen_vehicle_id INT;
    available_route_id INT;
BEGIN
    SELECT s.product_id, s.shipment_quantity, p.weight_per_unit, s.origin_warehouse_id, s.destination_address_id
    INTO shipment_rec
    FROM shipments s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.shipment_id = p_shipment_id;

    SELECT d.driver_id, d.vehicle_id
    INTO chosen_driver_id, chosen_vehicle_id
    FROM drivers d
    JOIN vehicles v ON d.vehicle_id = v.vehicle_id
    WHERE d.priority_level = p_priority_level
      AND v.capacity >= (shipment_rec.weight_per_unit * shipment_rec.shipment_quantity)
      AND v.status = 'active'
    LIMIT 1;

    SELECT r.route_id
    INTO available_route_id
    FROM routes r
    WHERE r.origin_address_id = shipment_rec.origin_warehouse_id
      AND r.destination_address_id = shipment_rec.destination_address_id
    LIMIT 1;

    UPDATE shipments
    SET driver_id = chosen_driver_id
    WHERE shipment_id = p_shipment_id;

    RETURN 'Shipment assigned to driver ' || chosen_driver_id || ' on route ' || available_route_id;
END;
$$ LANGUAGE plpgsql;

-- 16. TEST CASES
-- Test for calculate_shipping_cost
SELECT calculate_shipping_cost(1002, 1102, 5.5, 'overnight');

-- Test for update_shipment_status
SELECT update_shipment_status(5001, 'in_transit', 1101);

-- Test for generate_delivery_manifest
SELECT DISTINCT r.route_id, s.expected_delivery_date
FROM shipments s
JOIN routes r
  ON s.origin_warehouse_id = r.origin_address_id
 AND s.destination_address_id = r.destination_address_id
WHERE s.expected_delivery_date IS NOT NULL
ORDER BY s.expected_delivery_date
LIMIT 10;



select * from routes;
-- Test for assign_optimal_route
SELECT assign_optimal_route(5001, 'high');
