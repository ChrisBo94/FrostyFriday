use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_71;
use schema week_71;

-- Create the Sales table
CREATE OR REPLACE TABLE Sales (
    Sale_ID INT PRIMARY KEY,
    Product_IDs VARIANT --INT
);

-- Inserting sample sales data
INSERT INTO Sales (Sale_ID, Product_IDs) SELECT 1, PARSE_JSON('[1, 3]');-- Products A and C in the same sale
INSERT INTO Sales (Sale_ID, Product_IDs) SELECT 2, PARSE_JSON('[2, 4]');-- Products B and D in the same sale


-- Create the Products table
CREATE OR REPLACE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR,
    Product_Categories VARIANT --VARCHAR
);

-- Inserting sample data into Products
INSERT INTO Products (Product_ID, Product_Name, Product_Categories) SELECT 1, 'Product A', ARRAY_CONSTRUCT('Electronics', 'Gadgets');
INSERT INTO Products (Product_ID, Product_Name, Product_Categories) SELECT 2, 'Product B', ARRAY_CONSTRUCT('Clothing', 'Accessories');
INSERT INTO Products (Product_ID, Product_Name, Product_Categories) SELECT 3, 'Product C', ARRAY_CONSTRUCT('Electronics', 'Appliances');
INSERT INTO Products (Product_ID, Product_Name, Product_Categories) SELECT 4, 'Product D', ARRAY_CONSTRUCT('Clothing');


with flatten_sales as (
    select 
        sale_id,
        --Product_IDs,
        Productids.value::NUMBER as product_id
    from Sales,
    LATERAL FLATTEN(Sales.product_ids) Productids
),
flatten_products as (
    select 
        product_id,
        Product_Name,
        ProductCats.value::STRING as product_category
    from Products,
    LATERAL FLATTEN(Products.Product_Categories) ProductCats
),
product_join as (
    select
        s.sale_id,
        s.product_id,
        p.product_category
    from flatten_sales s
    LEFT JOIN flatten_products p 
    USING (product_id)
),
common_categories_actual_answer as (
    select
        sale_id,
        array_unique_agg(product_category) as commoncategories
    from product_join
    group by sale_id, product_id
),
common_categories_final_actual_answer as (
    select
        sale_id,
        array_unique_agg(commoncategories) as commoncategories
    from common_categories_actual_answer
    group by sale_id
),
common_categories_my_answer as (
    select
        sale_id,
        product_category,
        count(product_category)
    from product_join
    group by sale_id, product_category
    having count(product_category) > 1
),
common_categories_final_my_answer as (
    select
        sale_id,
        array_unique_agg(product_category) as commoncategories
    from common_categories_my_answer
    group by sale_id
)
select * from common_categories_final_actual_answer 
;
