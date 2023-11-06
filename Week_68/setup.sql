CREATE SCHEMA WEEK_68;
USE SCHEMA WEEK_68;

CREATE STAGE FF_WEEK_68_STAGE
  URL = 's3://frostyfridaychallenges/challenge_68/';

  list @FF_WEEK_68_STAGE;

  select $1,$2 from @FF_WEEK_68_STAGE;
  -- Columns are country, pop2023, density

  CREATE TABLE spanish_speaking_countries_2023_raw (val VARIANT); 

  copy into spanish_speaking_countries_2023_raw
  from @FF_WEEK_68_STAGE
  FILE_FORMAT = (TYPE = JSON STRIP_OUTER_ARRAY = TRUE);

  select * from spanish_speaking_countries_2023_raw;

CREATE VIEW spanish_speaking_countries_2023 AS
   SELECT
       val:country::VARCHAR as country,
       val:pop2023::NUMBER as pop2023, 
       val:density::NUMBER(38,10) as density
   FROM spanish_speaking_countries_2023_raw;

select * from spanish_speaking_countries_2023;

-- Created the app using the UI, but here is the generated SQL from the query history.
create STREAMLIT IDENTIFIER('"FROSTYFRIDAY"."WEEK_68"."R1X_A2_KEMKZ9KPE"') ROOT_LOCATION = '@FROSTYFRIDAY.WEEK_68."R1X_A2_KEMKZ9KPE (Stage)"' MAIN_FILE = '/streamlit_app.py' QUERY_WAREHOUSE = 'COMPUTE_WH' TITLE = 'FF_WEEK_68';
