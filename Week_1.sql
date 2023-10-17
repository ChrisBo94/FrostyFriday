CREATE SCHEMA FF_WEEK1;

-- Create CSV file format. Initialy only contained the first line, the second line of parameters was added after querying the data in the stage
create or replace file format FF_WEEK1_CSV type = 'csv' field_delimiter = ',' 
-- Each file started with "Result", so I made the assumption that it was the column header so ignored it. Also has possibility to use the parameter NULL_IF, but would need to check if the NULL should be a string value or not.
SKIP_HEADER=1 SKIP_BLANK_LINES=TRUE;

-- Creation of stage and assigning the file format previously created
create or replace stage FF_WEEK1_STAGE
  url='s3://frostyfridaychallenges/challenge_1/'
  file_format= FF_WEEK1_CSV
  ;

-- Checking to see what files are in the stage, and to verify the connection is valid
list @FF_WEEK1_STAGE;

-- Querying the data in the stage files to see how the files are structured
select metadata$filename, metadata$file_row_number,t.$1, t.$2 from @FF_WEEK1_STAGE t;

-- Creation of table to store the data
create or replace table FF_WEEK1_DATA (result varchar);

-- Copying the data from the staged files into the table
copy into FF_WEEK1_DATA from @FF_WEEK1_STAGE;

-- Querying the table to verify that the data was loaded in correctly
select * from FF_WEEK1_DATA;
