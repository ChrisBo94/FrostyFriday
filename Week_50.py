# The Snowpark package is required for Python Worksheets. 
# You can add more packages by selecting them using the Packages control and then importing them.

import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col

def main(session: snowpark.Session): 
    # Your code goes here, inside the "main" handler.
    tableName = 'WEEK_50.F_F_50'

    #USING SQL
    #dataframe = session.sql("select * from WEEK_50.F_F_50 where LAST_NAME = 'Deery'")
    
    #USING PYTHON
    dataframe = session.table(tableName).filter(col("LAST_NAME") == 'Deery')
    
    
    # Print a sample of the dataframe to standard output.
    #dataframe.show()

    # Return value will appear in the Results tab.
    return dataframe
