use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_55;
use schema week_55;

create or replace stage week55_stage
    url='s3://frostyfridaychallenges/challenge_55/'
    FILE_FORMAT = (TYPE = 'csv' FIELD_DELIMITER = ',' SKIP_HEADER = 1);

list @week55_stage;

  select $1,$2,$3,$4,$5,$6,$7,$8 from @week55_stage;



create or replace table sales_data (sale_id number, product varchar, quantity number, sale_date date, price number(38,2), country varchar, city varchar);

copy into sales_data
from @week55_stage;

select * from sales_data; 

select * from sales_data group by all order by sale_id;
