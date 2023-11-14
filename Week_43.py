# The Snowpark package is required for Python Worksheets. 
# You can add more packages by selecting them using the Packages control and then importing them.

import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import lit,json_extract_path_text

def main(session: snowpark.Session): 
    # Your code goes here, inside the "main" handler.
    tableName = 'frostyfriday.week_43.challenge_data'
    df = session.table(tableName)#.filter(col("language") == 'python')
    
    # Print a sample of the dataframe to standard output.
    #dataframe.collect()
    step1 = df.withColumn(
        "company_name",
        json_extract_path_text("json",lit("company_name"))
    ).withColumn(
        "company_website",
        json_extract_path_text("json",lit("company_website"))
    ).withColumn(
        "address",
        json_extract_path_text("json",lit("location.address"))
    ).withColumn(
        "city",
        json_extract_path_text("json",lit("location.city"))
    ).withColumn(
        "country",
        json_extract_path_text("json",lit("location.country"))
    ).withColumn(
        "state",
        json_extract_path_text("json",lit("location.state"))
    ).withColumn(
        "zip",
        json_extract_path_text("json",lit("location.zip"))
    )
    
    step2 =  step1.join_table_function("flatten", step1["json"], lit("superheroes")).drop("json").drop("seq").drop("key").drop("path").drop("index").drop("this")

    step3 =  step2.withColumn(
        "id",
        json_extract_path_text("value",lit("id"))
    ).withColumn(
        "name",
        json_extract_path_text("value",lit("name"))
    ).withColumn(
        "powers",
        json_extract_path_text("value",lit("powers"))
    ).withColumn(
        "real_name",
        json_extract_path_text("value",lit("real_name"))
    ).withColumn(
        "role",
        json_extract_path_text("value",lit("role"))
    ).withColumn(
        "years_of_experience",
        json_extract_path_text("value",lit("years_of_experience"))
    ).drop("value")

    # Return value will appear in the Results tab.
    return step3
