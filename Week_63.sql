--Schema creation
create or replace schema week_63;
use schema week_63;

--T1 creation
CREATE TABLE t1 (value CHAR(1));

INSERT INTO t1
SELECT 'a' FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS temp1

UNION ALL

SELECT 'b' FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20) AS temp2

UNION ALL

SELECT 'c' FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30) AS temp3

UNION ALL

SELECT 'd' FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20) AS temp4

;

-- Create table t2 and insert one 'b' value
CREATE TABLE t2 (value CHAR(1));
INSERT INTO t2 (value) VALUES ('b');

-- Create table t3 and insert ten 'c' values
CREATE TABLE t3 (value CHAR(1));
INSERT INTO t3
SELECT 'c' FROM (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS temp;

-- Create table t4 and insert one 'd' value
CREATE TABLE t4 (value CHAR(1));
INSERT INTO t4 (value) VALUES ('d');

-- Want to stop using cache for getting query_id without query result reuse
alter session set use_cached_result = false;

--Query to Check
SELECT *
FROM t1
    LEFT JOIN t2 ON t1.value = t2.value
    LEFT JOIN t3 ON t1.value = t3.value
    LEFT JOIN t4 ON t1.value = t4.value;

-- Set last Query ID to SQL Variable:
set last_id = last_query_id();
select $last_id;
    
-- Test explain plan, can't find the information here
EXPLAIN SELECT *
FROM t1
    LEFT JOIN t2 ON t1.value = t2.value
    LEFT JOIN t3 ON t1.value = t3.value
    LEFT JOIN t4 ON t1.value = t4.value;

-- So need to use get_query_operator_stats function instead
select
        --operator_id,
        operator_attributes:equality_join_condition::STRING as GUILTY_JOIN,
        operator_statistics:output_rows / operator_statistics:input_rows as row_multipliar
    from table(get_query_operator_stats($last_id))
    where operator_type = 'Join' 
    and row_multipliar > 1
    order by step_id, operator_id;

CREATE OR REPLACE FUNCTION FF_WEEK_63_UDF (QUERY_ID VARCHAR)
RETURNS TABLE(GUILTY_JOIN STRING, row_multipliar FLOAT)
LANGUAGE SQL
AS
$$
     select
        --operator_id,
        operator_attributes:equality_join_condition::STRING as GUILTY_JOIN,
        operator_statistics:output_rows / operator_statistics:input_rows as row_multipliar
    from table(get_query_operator_stats(QUERY_ID))
    where operator_type = 'Join' 
    and row_multipliar > 1
    order by step_id, operator_id
$$; 

select * from
TABLE(WEEK_63.FF_WEEK_63_UDF($last_id));
