SET search_path TO sales;

-- Total Sales and Quantity by Product
CREATE OR REPLACE VIEW v_sales_by_product AS
SELECT product_id, SUM(quantity) AS total_quantity, SUM(dollars_sold) AS total_sales
FROM sales_fact_table
GROUP BY product_id;

-- Top Performing Store by Revenue
CREATE OR REPLACE VIEW v_top_store AS
SELECT store_id, SUM(dollars_sold) AS total_sales
FROM sales_fact_table
GROUP BY store_id
ORDER BY total_sales DESC
LIMIT 1;

-- Top Performing Staff Member (All Time)
CREATE OR REPLACE VIEW v_top_staff_all_time AS
SELECT staff_id, SUM(quantity) AS total_items_sold
FROM sales_fact_table
GROUP BY staff_id
ORDER BY total_items_sold DESC
LIMIT 1;

-- Top Performing Staff Member (2017)
CREATE OR REPLACE VIEW v_top_staff_2017 AS
SELECT staff_id, SUM(quantity) AS total_items_sold
FROM sales_fact_table
WHERE EXTRACT(YEAR FROM order_date) = 2017
GROUP BY staff_id
ORDER BY total_items_sold DESC
LIMIT 1;

-- Top Performing Staff Member by Revenue (2018)
CREATE OR REPLACE VIEW v_top_staff_revenue_2018 AS
SELECT staff_id, SUM(dollars_sold) AS total_sales
FROM sales_fact_table
WHERE EXTRACT(YEAR FROM order_date) = 2018
GROUP BY staff_id
HAVING SUM(dollars_sold) = (
  SELECT MAX(sales_sum)
  FROM (
    SELECT staff_id, SUM(dollars_sold) AS sales_sum
    FROM sales_fact_table
    WHERE EXTRACT(YEAR FROM order_date) = 2018
    GROUP BY staff_id
  ) AS sales_by_staff
);

-- Best Year by Revenue
CREATE OR REPLACE VIEW v_best_year AS
SELECT EXTRACT(YEAR FROM order_date) AS sales_year, SUM(dollars_sold) AS total_sales
FROM sales_fact_table
GROUP BY sales_year
ORDER BY total_sales DESC
LIMIT 1;
