use role accountadmin;
GRANT EXECUTE ALERT ON ACCOUNT TO ROLE sysadmin;

CREATE NOTIFICATION INTEGRATION FF_EMAIL_INT
  TYPE=EMAIL
  ENABLED=TRUE;

  GRANT USAGE ON INTEGRATION FF_EMAIL_INT TO ROLE sysadmin;


use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_48;
use schema week_48;



CREATE OR REPLACE ALERT alert_long_queries
  WAREHOUSE = compute_wh
  SCHEDULE = '5 MINUTE'
  IF (EXISTS (
      SELECT *
      FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.QUERY_HISTORY())
      WHERE EXECUTION_STATUS ILIKE 'RUNNING'
        AND start_time < current_timestamp() - INTERVAL '5 MINUTES'
  ))
  THEN CALL SYSTEM$SEND_EMAIL(
  'FF_EMAIL_INT',
  'chris.boyles@capgemini.com',
  'Task has detected a long running query.'
  );
