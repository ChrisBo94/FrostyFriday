-- Create RAW data table with a single variant column
create or replace table FF_WEEK2_DATA (data variant);

-- Create Parquet File Format
create or replace file format FF_WEEK2 type = 'parquet'; 

-- Create Stage using Parquet File Format. Initially tried using a Table stage, but was hitting some limitations on being able to query parquet files from the table stage, so reverted back to an internal named stage instead.
create or replace stage FF_WEEK2_STAGE file_format = FF_WEEK2;

-- SnowSQL commands to be able to load the parquet files into my stage
--snowsql -a my.account -u my_user -r my_role
--USE DATABASE SANDBOX_CHRISBOYLES;
--PUT 'file:///Users/chris/Downloads/employees.parquet' @FF_WEEK2_STAGE;

-- Verify that the data was loaded into the stage by querying the stage directly
select metadata$filename, metadata$file_row_number,t.$1 from @FF_WEEK2_STAGE t;

-- Copy the data from the stage into the raw data table previously created
copy into FF_WEEK2_DATA from @FF_WEEK2_STAGE;

select * from FF_WEEK2_DATA;

-- Create a new table which selects the data from the variant column and casts it to a specific data type in it's own column
create or replace table FF_WEEK2 as (
SELECT
    data:city::VARCHAR as city,
    data:country::VARCHAR as country,
    data:country_code::VARCHAR as country_code,
    data:dept::VARCHAR as dept,
    data:education::VARCHAR as education,
    data:email::VARCHAR as email,
    data:employee_id::INTEGER as employee_id,
    data:first_name::VARCHAR as first_name,
    data:job_title::VARCHAR as job_title,
    data:last_name::VARCHAR as last_name,
    data:payroll_iban::VARCHAR as payroll_iban,
    data:postcode::VARCHAR as postcode,
    data:street_name::VARCHAR as street_name,
    data:street_num::NUMBER as street_num,
    data:time_zone::VARCHAR as time_zone,
    data:title::VARCHAR as title
    FROM FF_WEEK2_DATA
);

select * from FF_WEEK2;

-- Create a change tracking view, which only contains the PK of the table and the columns that you only want to see changes on, instead of the whole table
CREATE OR REPLACE VIEW FF_WEEK2_CT AS (
SELECT
employee_id,
dept,
job_title
FROM FF_WEEK2);

select * from FF_WEEK2_CT;

-- Create the stream on the view
CREATE STREAM FF_WEEK2_STREAM ON VIEW FF_WEEK2_CT;

-- Execute the provided update commands on the table
UPDATE FF_WEEK2 SET COUNTRY = 'Japan' WHERE EMPLOYEE_ID = 8;
UPDATE FF_WEEK2 SET LAST_NAME = 'Forester' WHERE EMPLOYEE_ID = 22;
UPDATE FF_WEEK2 SET DEPT = 'Marketing' WHERE EMPLOYEE_ID = 25;
UPDATE FF_WEEK2 SET TITLE = 'Ms' WHERE EMPLOYEE_ID = 32;
UPDATE FF_WEEK2 SET JOB_TITLE = 'Senior Financial Analyst' WHERE EMPLOYEE_ID = 68;

-- Verify that the stream has correctly only picked up the required columns and the result matches the challenge result.
select * from FF_WEEK2_STREAM;
