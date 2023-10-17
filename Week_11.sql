-- Create the stage that points at the data. Used an old week's csv format
create stage week_11_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_11/'
    file_format = 'FF_WEEK3_CSV';

-- Create the table as a CTAS statement.
create or replace table FF_WEEK11 as
select m.$1 as milking_datetime,
        m.$2 as cow_number,
        m.$3 as fat_percentage,
        m.$4 as farm_code,
        m.$5 as centrifuge_start_time,
        m.$6 as centrifuge_end_time,
        m.$7 as centrifuge_kwph,
        m.$8 as centrifuge_electricity_used,
        m.$9 as centrifuge_processing_time,
        m.$10 as task_used
from @week_11_frosty_stage (pattern => '.*milk_data.*[.]csv') m;

select * from FF_WEEK11;

-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create or replace task whole_milk_updates
    schedule = '1400 minutes'
    warehouse = 'ANALYTICS_WH'
as
    update FF_WEEK11 SET
    CENTRIFUGE_START_TIME = NULL,
    CENTRIFUGE_END_TIME = NULL,
    CENTRIFUGE_KWPH = NULL,
    TASK_USED = system$current_user_task_name() || ' at ' || current_timestamp()
    WHERE FAT_PERCENTAGE >= 3;


-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create or replace task skim_milk_updates
    warehouse = 'ANALYTICS_WH'
    after SANDBOX_CHRISBOYLES.PUBLIC.whole_milk_updates

as
    update FF_WEEK11 SET
    CENTRIFUGE_PROCESSING_TIME = DATEDIFF('minute',CENTRIFUGE_START_TIME,CENTRIFUGE_END_TIME),
    CENTRIFUGE_ELECTRICITY_USED = ROUND(((DATEDIFF('minute',CENTRIFUGE_START_TIME,CENTRIFUGE_END_TIME)/60) * CENTRIFUGE_KWPH),2),
    TASK_USED = system$current_user_task_name() || ' at ' || current_timestamp()
    WHERE FAT_PERCENTAGE < 3;

alter task skim_milk_updates resume;


-- Manually execute the task.
execute task whole_milk_updates;


-- Check that the data looks as it should.
select * from FF_WEEK11;

-- Check that the numbers are correct.
select task_used, count(*) as row_count from FF_WEEK11 group by task_used;
