create schema week_60;
use schema week_60;

use role sysadmin;

CREATE OR REPLACE TABLE challenge (
    name VARCHAR
);

INSERT INTO challenge (name)
VALUES
    ('John Smith'),
    ('Jon Smyth'),
    ('Jane Doe'),
    ('Jan Do'),
    ('Michael Johnson'),
    ('Mike Johnson'),
    ('Sarah Williams'),
    ('Sara Williams'),
    ('Robert Brown'),
    ('Roberto Brown'),
    ('Emily White'),
    ('Emilie Whyte'),
    ('David Lee'),
    ('Davey Li');

with name_id as (
    SELECT 
        ROW_NUMBER() OVER (Order by (select 1)) as row_no,
        name 
    FROM challenge
),
sounds_like as (
    SELECT
        a.row_no as row_to_check,
        b.row_no as row_checked_against,
        a.name as name_to_check,
        b.name as name_checked_against,
        IFF(SOUNDEX(a.name)=SOUNDEX(b.name),TRUE,FALSE) as sounds_familiar
    FROM name_id a
    LEFT JOIN name_id b
    WHERE a.row_no < b.row_no
) 
select * from sounds_like;
