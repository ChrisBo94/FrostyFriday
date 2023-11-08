use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;

-- database and schema creation
CREATE SCHEMA WEEK_54;

--table creation
CREATE TABLE table_a (
id INT,
name VARCHAR,
age INT
);

CREATE TABLE table_b (
id INT,
name VARCHAR,
age INT
);

--data creation
INSERT INTO table_a (id, name, age)
VALUES
(1, 'John', 25),
(2, 'Mary', 30),
(3, 'David', 28),
(4, 'Sarah', 35),
(5, 'Michael', 32),
(6, 'Emily', 27),
(7, 'Daniel', 29),
(8, 'Olivia', 31),
(9, 'Matthew', 26),
(10, 'Sophia', 33),
(11, 'Jacob', 24),
(12, 'Emma', 29),
(13, 'Joshua', 32),
(14, 'Ava', 30),
(15, 'Andrew', 28),
(16, 'Isabella', 34),
(17, 'James', 27),
(18, 'Mia', 31),
(19, 'Logan', 25),
(20, 'Charlotte', 29);

--role creation
use role useradmin;
CREATE ROLE week_54_role;
GRANT ROLE week_54_role to user chrisboyles ;
use role sysadmin;
GRANT USAGE ON database frostyfriday TO ROLE week_54_role;
GRANT USAGE ON schema WEEK_54 TO ROLE week_54_role;
GRANT SELECT ON ALL TABLES IN SCHEMA frostyfriday.WEEK_54 TO ROLE week_54_role;
GRANT INSERT ON ALL TABLES IN SCHEMA frostyfriday.WEEK_54 TO ROLE week_54_role;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE week_54_role;


with copy_to_table as procedure (fromTable STRING, toTable STRING, count INT) 
RETURNS STRING 
LANGUAGE PYTHON 
RUNTIME_VERSION = '3.8' 
PACKAGES = ('snowflake-snowpark-python') 
HANDLER = 'copyBetweenTables' 
AS 
$$ 
def copyBetweenTables(snowpark_session, fromTable, toTable, count): 
    snowpark_session.table(fromTable).limit(count).write.mode("append").save_as_table(toTable) 
    return "Success" 
$$ 
 CALL copy_to_table('table_a', 'table_b', 5)
;

select * from table_b;
