SET search_path TO sales, public;

/* 1. Dimensions */

CREATE TABLE sales.time AS 
SELECT DISTINCT   
    order_id,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(DAY FROM order_date) AS day
FROM public.orders;
ALTER TABLE sales.time ADD PRIMARY KEY (order_id);

CREATE TABLE sales.products AS
SELECT
    p.product_id,
    p.product_name,
    b.brand_name AS brand,
    c.category_name AS category,
    p.model_year,
    p.list_price
FROM public.products p
JOIN public.brands b ON p.brand_id = b.brand_id
JOIN public.categories c ON p.category_id = c.category_id;
ALTER TABLE sales.products ADD PRIMARY KEY (product_id);	

CREATE TABLE sales.staff AS 
SELECT staff_id, first_name, last_name, manager_id 
FROM public.staffs;
ALTER TABLE sales.staff ADD PRIMARY KEY (staff_id);
-- Fix hierarchy issue noted in original script
UPDATE sales.staff SET manager_id = 8 WHERE manager_id = 7;

CREATE TABLE sales.address AS 
SELECT DISTINCT   
    ROW_NUMBER() OVER (ORDER BY street, city, state, zip_code) AS address_id,
    street, city, state, zip_code 
FROM (
    SELECT street, city, state, zip_code FROM public.customers
    UNION
    SELECT street, city, state, zip_code FROM public.stores
) AS combined_addresses;
ALTER TABLE sales.address ADD PRIMARY KEY (address_id);

CREATE TABLE sales.customers AS
SELECT
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    email,
    a.address_id
FROM public.customers c
JOIN sales.address a ON c.street = a.street AND c.city = a.city AND c.state = a.state AND c.zip_code = a.zip_code;
ALTER TABLE sales.customers ADD PRIMARY KEY (customer_id);
ALTER TABLE sales.customers ADD FOREIGN KEY (address_id) REFERENCES sales.address(address_id);

CREATE TABLE sales.stores AS
SELECT
    store_id,
    store_name,
    a.address_id
FROM public.stores s
JOIN sales.address a ON s.street = a.street AND s.city = a.city AND s.state = a.state AND s.zip_code = a.zip_code;
ALTER TABLE sales.stores ADD PRIMARY KEY (store_id);
ALTER TABLE sales.stores ADD FOREIGN KEY (store_id) REFERENCES sales.address(address_id);

/* 2. Fact Table */

CREATE TABLE sales.sales_fact_table AS
SELECT
    order_id,
    order_date,
    product_id,
    store_id,
    customer_id,
    staff_id,
    quantity,
    dollars_sold
FROM (
    SELECT
        o1.order_id,
        TO_DATE(t.year || '-' || t.month || '-' || t.day, 'YYYY-MM-DD') AS order_date,
        oi.product_id,
        o1.store_id,
        o1.customer_id,
        o1.staff_id,
        oi.quantity,
        oi.quantity * oi.list_price * (1 - oi.discount) AS dollars_sold,
        ROW_NUMBER() OVER (PARTITION BY o1.order_id, oi.product_id ORDER BY o1.order_id, oi.product_id) AS row_num
    FROM public.orders o1
    JOIN sales.time t ON o1.order_id = t.order_id
    JOIN public.order_items oi ON o1.order_id = oi.order_id
    JOIN public.stores s ON o1.store_id = s.store_id
    JOIN public.staffs st ON o1.staff_id = st.staff_id
    JOIN public.customers c ON o1.customer_id = c.customer_id
) subquery
WHERE row_num = 1;

ALTER TABLE sales.sales_fact_table ADD PRIMARY KEY (order_id, product_id);
ALTER TABLE sales.sales_fact_table ADD FOREIGN KEY (product_id) REFERENCES sales.products (product_id);
ALTER TABLE sales.sales_fact_table ADD FOREIGN KEY (store_id) REFERENCES sales.stores (store_id);
ALTER TABLE sales.sales_fact_table ADD FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id);
ALTER TABLE sales.sales_fact_table ADD FOREIGN KEY (staff_id) REFERENCES sales.staff (staff_id);
