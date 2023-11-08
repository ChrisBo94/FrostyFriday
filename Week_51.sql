use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_51;
use schema week_51;

CREATE OR REPLACE TABLE week_51.FIREY_FRIDAY (ID INT, CHALLENGE VARCHAR, TOPIC VARCHAR);
INSERT INTO week_51.FIREY_FRIDAY (ID, CHALLENGE, TOPIC) VALUES
(1, 'Challenge 1', 'Arrays'),
(2, 'Challenge 2', 'Sorting Algorithms'),
(3, 'Challenge 3', 'Linked Lists'),
(4, 'Challenge 4', 'Stacks and Queues'),
(5, 'Challenge 5', 'Arrays'),
(6, 'Challenge 6', 'Graphs'),
(7, 'Challenge 7', 'Recursion'),
(8, 'Challenge 8', 'Dynamic Programming'),
(9, 'Challenge 9', 'Arrays'),
(10, 'Challenge 10', 'Bit Manipulation'),
(11, 'Challenge 11', 'String Manipulation'),
(12, 'Challenge 12', 'Graphs'),
(13, 'Challenge 13', 'Greedy Algorithms'),
(14, 'Challenge 14', 'Object-Oriented Programming'),
(15, 'Challenge 15', 'Arrays'),
(16, 'Challenge 16', 'Concurrency and Multithreading'),
(17, 'Challenge 17', 'Error Handling and Debugging'),
(18, 'Challenge 18', 'Design Patterns'),
(19, 'Challenge 19', 'Arrays'),
(20, 'Challenge 20', 'SQL Queries'),
(21, 'Challenge 21', 'RESTful APIs'),
(22, 'Challenge 22', 'Dynamic Programming'),
(23, 'Challenge 23', 'Containerization and Virtualization'),
(24, 'Challenge 24', 'CI/CD'),
(25, 'Challenge 25', 'Automated Testing'),
(26, 'Challenge 26', 'Web Security'),
(27, 'Challenge 27', 'Arrays'),
(28, 'Challenge 28', 'Networking Basics'),
(29, 'Challenge 29', 'Cloud Computing'),
(30, 'Challenge 30', 'Arrays'),
(31, 'Challenge 31', 'RESTful APIs'),
(32, 'Challenge 32', 'SQL Queries'),
(33, 'Challenge 33', 'Sorting Algorithms'),
(34, 'Challenge 34', 'Bit Manipulation'),
(35, 'Challenge 35', 'Graphs'),
(36, 'Challenge 36', 'Object-Oriented Programming'),
(37, 'Challenge 37', 'String Manipulation'),
(38, 'Challenge 38', 'Concurrency and Multithreading'),
(39, 'Challenge 39', 'Design Patterns'),
(40, 'Challenge 40', 'Error Handling and Debugging'),
(41, 'Challenge 41', 'CI/CD'),
(42, 'Challenge 42', 'Automated Testing'),
(43, 'Challenge 43', 'Web Security'),
(44, 'Challenge 44', 'Arrays'),
(45, 'Challenge 45', 'Networking Basics'),
(46, 'Challenge 46', 'Cloud Computing'),
(47, 'Challenge 47', 'Containerization and Virtualization'),
(48, 'Challenge 48', 'RESTful APIs'),
(49, 'Challenge 49', 'Dynamic Programming'),
(50, 'Challenge 50', 'SQL Queries');

with top_3 as (
    select 
        TOP 3 TOPIC,
        'TOP_' || DENSE_RANK() OVER (order by count(*) DESC, topic ) AS RANK
    from FIREY_FRIDAY
    group by TOPIC
    order by count(*) DESC
)
select 
    TOP_1,
    TOP_2,
    TOP_3
INTO
    :TOP_1,
    :TOP_2,
    :TOP_3
from
top_3
PIVOT(MIN(TOPIC) FOR RANK IN ('TOP_1','TOP_2','TOP_3'))
as p (TOP_1,TOP_2,TOP_3);

-- Cheating a little as I'm not creating this within the App. But I'm not able to install SnowSQL on this work machine, so can't PUT the files in the stage easily. So here it is as just a normal stored procedure

create or replace procedure TOP_3_TOPICS()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    TOP_1 VARCHAR;
    TOP_2 VARCHAR;
    TOP_3 VARCHAR;
    return_string VARCHAR;
BEGIN
   
   with top_3 as (
    select 
        TOP 3 TOPIC,
        'TOP_' || DENSE_RANK() OVER (order by count(*) DESC, topic ) AS RANK
    from FIREY_FRIDAY
    group by TOPIC
    order by count(*) DESC
    )
    select 
        TOP_1,
        TOP_2,
        TOP_3
    INTO
        :TOP_1,
        :TOP_2,
        :TOP_3
    from
    top_3
    PIVOT(MIN(TOPIC) FOR RANK IN ('TOP_1','TOP_2','TOP_3'))
    as p (TOP_1,TOP_2,TOP_3); 

    return_string := 'Oh, they are obsessed with ' || TOP_1 || ', how weird. And then it\'s all about ' || TOP_2 || ' and ' || TOP_3 || '. How pathetic!';

    return return_string;
END;
$$;

call TOP_3_TOPICS();
