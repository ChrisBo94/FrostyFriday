use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_53;
use schema week_53;

create stage frosty_stage;

create or replace file format frosty_csv
field_optionally_enclosed_by = '"'
skip_header = 1;

PUT 'file://C:\Users\cboyles\Downloads\employees.csv' @frosty_stage AUTO_COMPRESS=TRUE;


SELECT 
    ORDER_ID + 1 AS COLUMN_POSITION,
    TYPE AS DATA_TYPE
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@frosty_stage/'
      , FILE_FORMAT=>'frosty_csv'
      )
    );
