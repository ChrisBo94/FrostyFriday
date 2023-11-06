# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Write directly to the app
st.title("Spanish Speaking Countries by Pop")


# Get the current credentials
session = get_active_session()


#  Create an example dataframe
#  Note: this is just some dummy data, but you can easily connect to your Snowflake data
#  It is also possible to query data using raw SQL using session.sql() e.g. session.sql("select * from table")
created_dataframe = session.table("FROSTYFRIDAY.WEEK_68.spanish_speaking_countries_2023")

# Execute the query and convert it into a Pandas dataframe
queried_data = created_dataframe.to_pandas()

# Create a simple bar chart
# See docs.streamlit.io for more types of charts
#st.subheader("Number of high-fives")
st.bar_chart(data=queried_data, x="COUNTRY", y="POP2023")
