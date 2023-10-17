import streamlit as st
import pandas as pd
import snowflake.connector
from datetime import date


# Initialize connection.
# Uses st.experimental_singleton to only run once.
@st.experimental_singleton
def init_connection():
    return snowflake.connector.connect(**st.secrets["snowflake"])

conn = init_connection()

query = "SELECT DATE(payment_date) as payment_date, DATE_TRUNC('week',payment_date) as payment_week, amount_spent from FF_WEEK8_PAYMENTS;"

@st.cache
def load_data(query):
    """
    In Python, def() creates a function. This particular function connects to your Snowflake
    account and executes the query above. If you have no Python experience, I recommend leaving
    this alone.
    """
    cur = conn.cursor().execute(query)
    payments_df = pd.DataFrame.from_records(iter(cur), columns=[x[0] for x in cur.description])
    payments_df['PAYMENT_DATE'] = pd.to_datetime(payments_df['PAYMENT_DATE'],format="%Y-%m-%d")
    payments_df['PAYMENT_WEEK'] = pd.to_datetime(payments_df['PAYMENT_WEEK'],format="%Y-%m-%d")
    payments_df['AMOUNT_SPENT'] = pd.to_numeric(payments_df['AMOUNT_SPENT'])
    #payments_df = payments_df.set_index('PAYMENT_DATE')

    min_date = payments_df['PAYMENT_DATE'].min()
    max_date = payments_df['PAYMENT_DATE'].max()

    return payments_df, min_date, max_date


def filter_data(payments_df,minimum_date,maximum_date):
    date_filter = payments_df['PAYMENT_DATE'].between(pd.to_datetime(minimum_date),pd.to_datetime(maximum_date),inclusive="both")

    date_filtered = payments_df[date_filter]

    group_filtered = date_filtered.groupby(['PAYMENT_WEEK'])['AMOUNT_SPENT'].sum()

    return group_filtered



def build_app():
    st.title('Payments in 2021')

    payments_df, min_date, max_date = load_data(query)

    minimum_date = st.slider(
        "Select min date:",
        min_value=min_date.date(),
        max_value=max_date.date(),
        value=min_date.date(),
        format="YYYY-MM-DD")

    maximum_date = st.slider(
        "Select max date:",
        min_value=min_date.date(),
        max_value=max_date.date(),
        value=max_date.date(),
        format="YYYY-MM-DD")

    payments_df_filtered = filter_data(payments_df,minimum_date,maximum_date)

    st.line_chart(
        payments_df_filtered,
        y="AMOUNT_SPENT"
        )

build_app()