use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_49;
use schema week_49;

create table challenge_data (
    data variant
);

insert into challenge_data
select parse_xml('<?xml version="1.0" encoding="UTF-8"?>
<library>
    <book>
        <title>The Great Gatsby</title>
        <author>F. Scott Fitzgerald</author>
        <year>1925</year>
        <publisher>Scribner</publisher>
    </book>
    <book>
        <title>To Kill a Mockingbird</title>
        <author>Harper Lee</author>
        <year>1960</year>
        <publisher>J. B. Lippincott & Co.</publisher>
    </book>
    <book>
        <title>1984</title>
        <author>George Orwell</author>
        <year>1949</year>
        <publisher>Secker & Warburg</publisher>
    </book>
</library>
');


select
    --BOOKS.value,
    XMLGET(BOOKS.value,'title'):"$"::STRING as title,
    XMLGET(BOOKS.value,'author'):"$"::STRING as author,
    XMLGET(BOOKS.value,'year'):"$"::NUMBER as year,
    XMLGET(BOOKS.value,'publisher'):"$"::STRING as publisher
from week_49.challenge_data,
LATERAL FLATTEN(DATA:"$") BOOKS
