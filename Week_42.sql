use role accountadmin;
grant execute managed task on account to role sysadmin;
grant execute task on account to role sysadmin;

use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_42;
use schema week_42;




create table kids_out_of_bed (
    Time TIMESTAMP_NTZ,
    Joan BOOLEAN DEFAULT FALSE,
    Maggy BOOLEAN DEFAULT FALSE,
    Jason BOOLEAN DEFAULT FALSE
);

--Merge statement to run at start of task to set out of bed to TRUE
MERGE INTO kids_out_of_bed 
USING (SELECT DATE_TRUNC('minute',CURRENT_TIMESTAMP::TIMESTAMP_NTZ) as cur_time) 
ON time=cur_time
WHEN MATCHED THEN UPDATE SET JOAN = TRUE
WHEN NOT MATCHED THEN INSERT (TIME,JOAN) VALUES (cur_time,TRUE);

--Merge statement to run at end of task to set out of bed to FALSE
MERGE INTO kids_out_of_bed 
USING (SELECT DATE_TRUNC('minute',CURRENT_TIMESTAMP::TIMESTAMP_NTZ) as cur_time) 
ON time=cur_time
WHEN MATCHED THEN UPDATE SET JOAN = FALSE
WHEN NOT MATCHED THEN INSERT (TIME,JOAN) VALUES (cur_time,FALSE);

select * from kids_out_of_bed;
truncate kids_out_of_bed;

create or replace task joan_out_of_bed
    SCHEDULE = '3 MINUTE'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
BEGIN
    MERGE INTO kids_out_of_bed 
    USING (SELECT DATE_TRUNC('minute',CURRENT_TIMESTAMP::TIMESTAMP_NTZ) as cur_time) 
    ON time=cur_time
    WHEN MATCHED THEN UPDATE SET JOAN = TRUE
    WHEN NOT MATCHED THEN INSERT (TIME,JOAN) VALUES (cur_time,TRUE);

    CALL SYSTEM$WAIT(1, 'MINUTES');

    MERGE INTO kids_out_of_bed 
    USING (SELECT DATE_TRUNC('minute',CURRENT_TIMESTAMP::TIMESTAMP_NTZ) as cur_time) 
    ON time=cur_time
    WHEN MATCHED THEN UPDATE SET JOAN = TRUE
    WHEN NOT MATCHED THEN INSERT (TIME,JOAN) VALUES (cur_time,TRUE);
    
END;


create or replace task maggy_out_of_bed
    SCHEDULE = '5 MINUTE'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
BEGIN
    MERGE INTO kids_out_of_bed 
    USING (SELECT DATE_TRUNC('minute',CURRENT_TIMESTAMP::TIMESTAMP_NTZ) as cur_time) 
    ON time=cur_time
    WHEN MATCHED THEN UPDATE SET MAGGY = TRUE
    WHEN NOT MATCHED THEN INSERT (TIME,MAGGY) VALUES (cur_time,TRUE);

    
END;

create or replace task jason_out_of_bed
    SCHEDULE = '13 MINUTE'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
BEGIN
    MERGE INTO kids_out_of_bed 
    USING (SELECT DATE_TRUNC('minute',CURRENT_TIMESTAMP::TIMESTAMP_NTZ) as cur_time) 
    ON time=cur_time
    WHEN MATCHED THEN UPDATE SET JASON = TRUE
    WHEN NOT MATCHED THEN INSERT (TIME,JASON) VALUES (cur_time,TRUE);

END;

create task dad_checking_on_kids
    SCHEDULE = '1 MINUTE'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
BEGIN
    CASE WHEN EXISTS (
        with max_timestamp as (
            select
                max(TIME) as max_time
            from kids_out_of_bed
        )
            SELECT 1 
            FROM kids_out_of_bed
            JOIN max_timestamp
            ON max_time = TIME
            WHERE JOAN = TRUE
            AND MAGGY = TRUE
            AND JASON = TRUE
        )
        THEN 
            ALTER TASK joan_out_of_bed suspend;
            ALTER TASK maggy_out_of_bed suspend;
            ALTER TASK jason_out_of_bed suspend;
            ALTER TASK dad_checking_on_kids suspend;
        END CASE;
END;

select * from kids_out_of_bed;
truncate kids_out_of_bed;

--kicked off all the tasks at 2023-11-14 07:10
ALTER TASK joan_out_of_bed resume;
ALTER TASK maggy_out_of_bed resume;
ALTER TASK jason_out_of_bed resume;
ALTER TASK dad_checking_on_kids resume;

select * from kids_out_of_bed;
