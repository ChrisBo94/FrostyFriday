CREATE SCHEMA WEEK_61;
USE SCHEMA WEEK_61;

CREATE OR REPLACE STAGE FF_WEEK_61_STAGE
  URL = 's3://frostyfridaychallenges/challenge_61/';

  list @FF_WEEK_61_STAGE;

  select $1,$2,$3,$4,$5,$6,$7 from @FF_WEEK_61_STAGE;
  -- Columns are country, pop2023, density

  CREATE OR REPLACE TABLE telecom_products (row_number NUMBER, brand VARCHAR,url VARCHAR,product_name VARCHAR,category VARCHAR,friendly_url VARCHAR); 

CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1;

  copy into telecom_products
  from (
      select
          metadata$file_row_number,
          $1::VARCHAR,
          $2::VARCHAR,
          $3::VARCHAR,
          $4::VARCHAR,
          $5::VARCHAR
  from @FF_WEEK_61_STAGE
  (FILE_FORMAT => 'csv_format')
  );

  truncate telecom_products;
  select * from telecom_products;

create or replace view telecom_products_clean as
    SELECT
        IFF(BRAND IS NULL,LAG(BRAND) IGNORE NULLS OVER (ORDER BY ROW_NUMBER ASC),BRAND) AS BRAND,
        PRODUCT_NAME,
        CATEGORY,
        NVL(FRIENDLY_URL,URL) AS FRIENDLY_URL
    FROM telecom_products
    where category is not null;

select * from telecom_products_clean;

CREATE OR REPLACE VIEW telecom_products_json_output as 
with product_url as (
    SELECT
        CATEGORY,
        BRAND,
        ARRAY_UNIQUE_AGG(OBJECT_CONSTRUCT(PRODUCT_NAME, FRIENDLY_URL)) as PROD_URL
    FROM telecom_products_clean
    group by CATEGORY, BRAND
),
brand_product as (
    SELECT
        CATEGORY, 
        OBJECT_AGG(  BRAND, PROD_URL) AS BRAND_PROD
    FROM product_url
    group by CATEGORY
),
category_brand as (
    SELECT
        OBJECT_AGG(CATEGORY,BRAND_PROD)
    FROM brand_product
)
select * from category_brand;

create file format json_format type = JSON;

create stage week_63_json_stage file_format = json_format;

copy into @week_63_json_stage from telecom_products_json_output;

list @week_63_json_stage;

select GET_PRESIGNED_URL(@week_63_json_stage, 'data_0_0_0.json.gz');
