use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_52;
use schema week_52;

CREATE OR REPLACE PROCEDURE check_and_generate_data(tableName STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
try {
var tableName = TABLENAME;

var command1 = `SELECT count(*) as count FROM information_schema.tables WHERE table_schema = CURRENT_SCHEMA() AND table_name = '${tableName.toUpperCase()}'`;
var statement1 = snowflake.createStatement({sqlText: command1});
var result_set1 = statement1.execute();

result_set1.next();
var count = result_set1.getColumnValue('COUNT');

if (count == 0) {
    var command2 = `CREATE TABLE ${tableName} (payload VARIANT, ingested_at TIMESTAMP_NTZ default CURRENT_TIMESTAMP())`;
    var statement2 = snowflake.createStatement({sqlText: command2});
    statement2.execute();

    return `Table ${tableName} has been created.`;
} else {
    for(var i=0; i<40; i++) {
        var jsonObject = {
            "id": i,
            "name": "Name_" + i,
            "address": "Address_" + i,
            "email": "email_" + i + "@example.com",
            "transactionValue": Math.floor(Math.random() * 10000) + 1
        };
        var jsonString = JSON.stringify(jsonObject);

        var command3 = `INSERT INTO ${tableName} (payload) SELECT PARSE_JSON(column1) FROM VALUES ('${jsonString}')`;
        var statement3 = snowflake.createStatement({sqlText: command3});
        statement3.execute();
    }

    return `40 records have been inserted into the ${tableName} table.`;
}

} catch (err) {
return "Failed: " + err;
}
$$;

call check_and_generate_data('CHALLENGE_52');

select * from challenge_52;


CREATE OR REPLACE DYNAMIC TABLE challenge_52_dynamic_table
TARGET_LAG = '1 minute'
WAREHOUSE = compute_wh
AS
SELECT 
    PAYLOAD:address::string address, 
    PAYLOAD:email::string email,
    PAYLOAD:id::NUMBER id,
    PAYLOAD:transactionValue::NUMBER(38,2) transaction_value,
    PAYLOAD:name::string name,
    ingested_at
FROM challenge_52;

select * from challenge_52_dynamic_table;
