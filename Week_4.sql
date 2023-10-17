-- Create RAW data table with a single variant column
create or replace table FF_WEEK4_DATA (data variant);

-- Create json File Format
create or replace file format FF_WEEK4 type = 'json' STRIP_OUTER_ARRAY=true; 

-- Create Stage using json File Format. Initially tried using a Table stage, but was hitting some limitations on being able to query parquet files from the table stage, so reverted back to an internal named stage instead.
create or replace stage FF_WEEK4_STAGE file_format = FF_WEEK4;

-- SnowSQL commands to be able to load the parquet files into my stage
--snowsql -a my.account -u my_user -r my_role
--USE DATABASE SANDBOX_CHRISBOYLES;
--PUT 'file:///Users/chris/Downloads/Spanish_Monarchs.json' @FF_WEEK4_STAGE;

-- Verify that the data was loaded into the stage by querying the stage directly
select metadata$filename, metadata$file_row_number,t.$1 from @FF_WEEK4_STAGE t;


-- Copy the data from the stage into the raw data table previously created
copy into FF_WEEK4_DATA from @FF_WEEK4_STAGE;

select * from FF_WEEK4_DATA;

-- Create a new table which parses the JSON using lateral flattens to pull out the nested JSON data
CREATE OR REPLACE TABLE FF_WEEK4 as (
    select 
    row_number() over (order by monarchs.value:"Birth"::DATE asc, monarchs.value:"Start of Reign"::DATE asc) as id,
    monarchs.index + 1 as inter_house_id,
    data:"Era"::VARCHAR as era,
    houses.value:"House"::VARCHAR as house,
    monarchs.value:"Name"::VARCHAR as name,
    CASE WHEN IS_ARRAY(monarchs.value:"Nickname") THEN monarchs.value:"Nickname"[0]::VARCHAR ELSE 
    monarchs.value:"Nickname"::VARCHAR END as nickname_1,
    monarchs.value:"Nickname"[1]::VARCHAR as nickname_2,
    monarchs.value:"Nickname"[2]::VARCHAR as nickname_3,
    monarchs.value:"Birth"::DATE as birth,
    monarchs.value:"Place of Birth"::VARCHAR as place_of_birth,
    monarchs.value:"Start of Reign"::DATE as start_of_reign,
    CASE WHEN IS_ARRAY(monarchs.value:"Consort\/Queen Consort") THEN monarchs.value:"Consort\/Queen Consort"[0]::VARCHAR ELSE
    monarchs.value:"Consort\/Queen Consort"::VARCHAR END as queen_or_queen_consort_1,
    monarchs.value:"Consort\/Queen Consort"[1]::VARCHAR as queen_or_queen_consort_2,
    monarchs.value:"Consort\/Queen Consort"[2]::VARCHAR as queen_or_queen_consort_3,
    monarchs.value:"End of Reign"::DATE as end_of_reign,
    monarchs.value:"Duration"::VARCHAR as duration,
    monarchs.value:"Death"::DATE as death,
    SPLIT_PART(monarchs.value:"Age at Time of Death",' ',1)::INTEGER as age_at_time_of_death_years,
    monarchs.value:"Place of Death"::VARCHAR as place_of_death,
    monarchs.value:"Burial Place"::VARCHAR as burial_place
    from FF_WEEK4_DATA,
    lateral flatten( input => data:"Houses") houses,
    lateral flatten( input => houses.value:"Monarchs") monarchs
    );
    
    
select * from FF_WEEK4;
