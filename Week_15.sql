use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_15;
use schema week_15;

create table home_sales (
sale_date date,
price number(11, 2)
);

insert into home_sales (sale_date, price) values
('2013-08-01'::date, 290000.00),
('2014-02-01'::date, 320000.00),
('2015-04-01'::date, 399999.99),
('2016-04-01'::date, 400000.00),
('2017-04-01'::date, 470000.00),
('2018-04-01'::date, 510000.00);
drop procedure price_bin(float, variant);

create or replace function price_bin(price float, bin_ranges array)
returns string
language python
runtime_version = '3.8'
handler = 'price_bin'
as
$$
def price_bin(price,bin_ranges):
    bin_no = 1
    output_range = None

    for bin in bin_ranges:
        bins = bin.split("-")
        lower_bound = int(bins[0])
        upper_bound = int(bins[1])

        if price >= lower_bound and price <= upper_bound:
            output_range = bin_no

        bin_no += 1


    # Return value will appear in the Results tab.
    return output_range
$$;


SELECT sale_date,
       price,
       price_bin(price,ARRAY_CONSTRUCT('0-1','2-310000','310001-400000','400001-500000')) AS BUCKET_SET1,
       price_bin(price,ARRAY_CONSTRUCT('0-210000','210000-350000')) AS BUCKET_SET2,
       price_bin(price,ARRAY_CONSTRUCT('0-250000','250001-290001','290002-320000','320001-360000','360001-410000','410001-470001')) AS BUCKET_SET3
FROM home_sales;
