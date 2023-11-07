create schema week_64;

create or replace file format frosty_parquet
type = 'parquet';

create or replace stage s3_stage
    url = 's3://frostyfridaychallenges';
    
create or replace table challenge as
select parse_xml($1:"DATA") as raw_xml
from @s3_stage/challenge_64/french_monarchs.parquet
    (file_format => frosty_parquet);

select raw_xml::VARCHAR from challenge;

select PARSE_XML(DATA) from challenge;
select XMLGET( data, 'Monarchs' ):"$"::STRING from challenge;


CREATE OR REPLACE VIEW MONARCHS_THROUGH_TIME AS 
SELECT
    --DYNASTIES.value,
    --DYNASTIES.value:"$",
    GET(  DYNASTIES.value, '@name' )::STRING as DYNASTY,
    --MONARCHS.value,
    XMLGET( MONARCHS.value, 'Name' ):"$"::STRING as Monarch_Name,
    XMLGET( MONARCHS.value, 'Reign' ):"$"::STRING as Reign,
    XMLGET( MONARCHS.value, 'Succession' ):"$"::STRING as Succession,
    XMLGET( MONARCHS.value, 'LifeDetails' ):"$"::STRING as Life_Details
FROM challenge,
LATERAL FLATTEN(raw_xml:"$") DYNASTIES,
LATERAL FLATTEN(TO_ARRAY(DYNASTIES.value:"$")) MONARCHS;

SELECT * FROM MONARCHS_THROUGH_TIME;
