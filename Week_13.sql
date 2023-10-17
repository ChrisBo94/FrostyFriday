-- Starter code to create tester data
Create schema FF_WEEK13;
use schema ff_week13;

create or replace table testing_data(id int autoincrement start 1 increment 1, product string, stock_amount int,date_of_check date);
-- Inserting test data
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',1,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',2,'2022-01-02');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',NULL,'2022-02-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero capes',NULL,'2022-03-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',5,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-13');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',6,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',NULL,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',3,'2022-04-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',2,'2022-07-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',NULL,'2022-01-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',3,'2022-05-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero pants',NULL,'2022-10-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',10,'2022-11-01');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-14');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-15');
insert into testing_data (product,stock_amount,date_of_check) values ('Superhero masks',NULL,'2022-02-13');

select * from testing_data;

-- Solution using Snowflake's out of the box lag function, ignoring nulls
create or replace VIEW FF_WEEK13_LAG_SOLUTION AS(
select 
    id,
    product,
    stock_amount,
    coalesce(stock_amount, lag(stock_amount) ignore nulls over (partition by product order by date_of_check, id)) as stock_amount_filled_out,
    date_of_check
from testing_data
order by product, date_of_check, id);

select * from FF_WEEK13_LAG_SOLUTION;

-- CTE Solution, joining back to itself
create or replace VIEW FF_WEEK13_CTE_SOLUTION AS(
-- First CTE only shows dates where the product's stock amount was filled in
with populated_stock_amounts as (
    select
        PRODUCT,
        STOCK_AMOUNT,
        DATE_OF_CHECK
    from TESTING_DATA
    where STOCK_AMOUNT IS NOT NULL
),
-- Second CTE works out the last time a product's stock was check, but only if the product hasn't had a stock amount filled in on the date of the check
last_stock_date_checks as (
select
    td.ID,
    td.PRODUCT,
    td.DATE_OF_CHECK,
    (
        select max(psa.DATE_OF_CHECK)
        from populated_stock_amounts psa
        where psa.product = td.product and psa.DATE_OF_CHECK <= td.DATE_OF_CHECK
    ) as LAST_DATE_CHECK
    from TESTING_DATA td
    where td.stock_amount IS NULL
    order by td.product, td.date_of_check, td.id
),
-- Third CTE joins the last date checked, with the populated amount from that date (joining the 2 previous CTEs together). This gives the last populated amount for all checks which had missing values
last_stock_date_amounts as (
    select
    lsdc.ID,
    lsdc.PRODUCT,
    lsdc.DATE_OF_CHECK,
    populated_stock_amounts.stock_amount as calculated_stock_amount
    from last_stock_date_checks lsdc
    left join populated_stock_amounts on populated_stock_amounts.date_of_check=lsdc.LAST_DATE_CHECK and populated_stock_amounts.product=lsdc.product
) 
-- Last select coalesces the main testing data with the last CTE, so it grabs the value only if it is null
select
    td1.id,
    td1.product,
    td1.stock_amount,
    COALESCE( td1.stock_amount,lsda.calculated_stock_amount) as stock_amount_filled_out,
    td1.date_of_check
from TESTING_DATA td1
LEFT JOIN last_stock_date_amounts lsda on td1.id=lsda.id
order by product, date_of_check, id);


select * from FF_WEEK13_CTE_SOLUTION;


