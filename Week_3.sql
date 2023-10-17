-- Create CSV file format. Initialy only contained the first line, the second line of parameters was added after querying the data in the stage
create or replace file format FF_WEEK3_CSV type = 'csv' field_delimiter = ','
-- Each file started with "Result", so I made the assumption that it was the column header so ignored it. Also has possibility to use the parameter NULL_IF, but would need to check if the NULL should be a string value or not.
SKIP_HEADER=1 SKIP_BLANK_LINES=TRUE;

-- Creation of stage and assigning the file format previously created
create or replace stage FF_WEEK3_STAGE
  url='s3://frostyfridaychallenges/challenge_3/'
  file_format= FF_WEEK3_CSV
  ;

-- Checking to see what files are in the stage, and to verify the connection is valid
list @FF_WEEK3_STAGE;

-- Looking at the format of the data files (non-keyword files)
select metadata$filename, metadata$file_row_number, t.$1, t.$2, t.$3, t.$4, t.$5 from @FF_WEEK3_STAGE t where not CONTAINS(metadata$filename,'keywords');

-- Creation of table to store the data
create or replace table FF_WEEK3_DATA (
filename varchar,
file_row_number number,
id number,
first_name varchar,
last_name varchar,
catch_phrase varchar,
timestamp date);

-- Copying the data from the staged files into the data table
copy into FF_WEEK3_DATA from (
    select metadata$filename, metadata$file_row_number, t.$1, t.$2, t.$3, t.$4, t.$5 
    from @FF_WEEK3_STAGE/week3 t);

select * from FF_WEEK3_DATA;

-- Querying the data in the stage files to see how the keywords file is structured
select t.$1,t.$2,t.$3 from @FF_WEEK3_STAGE t where CONTAINS(metadata$filename,'keywords');

-- Creation of table to store the keywrods
create or replace table FF_WEEK3_KEYWORDS (
keyword varchar,
added_by varchar,
other varchar);

-- Copying the data from the staged keywords file into the keywords table
copy into FF_WEEK3_KEYWORDS from @FF_WEEK3_STAGE pattern = '.*keywords.*[.]csv';

select * from FF_WEEK3_KEYWORDS;

-- Query to only return files which contain the keyword in the filename using a subquery
select d.filename, count(d.file_row_number) 
from FF_WEEK3_DATA d 
where exists(
    select 1 
    from FF_WEEK3_KEYWORDS k 
    where contains(d.filename, k.keyword)
)
group by d.filename;

-- Second Approach using LIKE ANY, still using a subquery
select d.filename, count(d.file_row_number) 
from FF_WEEK3_DATA d 
where d.filename like any (
    select '%'||keyword||'%' 
    from FF_WEEK3_KEYWORDS)
group by d.filename;
