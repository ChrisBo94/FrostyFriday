import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col

def main(session: snowpark.Session): 
    tableName = 'snowflake.account_usage.tables'
    dataframe = session.table(tableName).filter(col("ROW_COUNT") > 0).filter(col("IS_TRANSIENT") == "NO").filter( col("DELETED").is_null() ).with_column_renamed(col("TABLE_CATALOG"), "DATABASE")

    dataframe2 = dataframe.group_by(['DATABASE']).count()

    import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col

def main(session: snowpark.Session): 
    tableName = 'snowflake.account_usage.tables'
    df = session.table(tableName).filter(col("ROW_COUNT") > 0).filter(col("IS_TRANSIENT") == "NO").filter( col("DELETED").is_null() ).with_column_renamed(col("TABLE_CATALOG"), "DATABASE")

    df_grouped = df.group_by(['DATABASE']).count()

    df_renamed = df_grouped.with_column_renamed(col("COUNT"), "TABLES")

    return df_renamed
