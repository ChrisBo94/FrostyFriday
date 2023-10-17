-- Create the table
create or replace table FF_WEEK10
(
    date_time datetime,
    trans_amount double
);

-- Create CSV file format. Initialy only contained the first line, the second line of parameters was added after querying the data in the stage
create or replace file format FF_WEEK10_CSV type = 'csv' field_delimiter = ','
-- Each file started with "Result", so I made the assumption that it was the column header so ignored it. Also has possibility to use the parameter NULL_IF, but would need to check if the NULL should be a string value or not.
SKIP_HEADER=1 SKIP_BLANK_LINES=TRUE FIELD_OPTIONALLY_ENCLOSED_BY='"';

-- Create the stage
create or replace stage FF_WEEK10_STAGE
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = FF_WEEK10_CSV;

list @FF_WEEK10_STAGE;

-- Create the stored procedure
create or replace procedure dynamic_warehouse_data_load(stage_name string, table_name string)
RETURNS string
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'run'
EXECUTE AS CALLER
AS
$$
def run(session,stage_name,table_name):
    create_stage_result = session.sql("list @" + stage_name).collect()
    result=[]
    for file in create_stage_result:
        name = "@" + stage_name + "/" + file[0].split('/')[-1]
        size = int(file[1])
        #result.append([name,size])
        if size > 10000:
            usewh = session.sql("USE WAREHOUSE ANALYTICS_WH").collect()
        else:
            usewh = session.sql("USE WAREHOUSE DATA_ENGINEER_WH").collect()
        copy = session.sql("copy into " + table_name + " from " + name).collect()    

    result = session.sql("select count(*) from " + table_name).collect()
    
    tbl = session.table(table_name)

    count = str(tbl.count()) + " rows were added"
    
    return count
$$;


-- Call the stored procedure.
call dynamic_warehouse_data_load('FF_WEEK10_STAGE', 'FF_WEEK10');
