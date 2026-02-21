import streamlit as st
import snowflake.connector

st.title("Clinical Dashboard: Wearable Data")

# Snowflake connection
conn = snowflake.connector.connect(
    user="YOUR_USER",
    password="YOUR_PASSWORD",
    account="YOUR_ACCOUNT",
    warehouse="YOUR_WAREHOUSE",
    database="YOUR_DATABASE",
    schema="YOUR_SCHEMA"
)

patient_id = st.text_input("Enter Patient ID:")

if patient_id:
    query = f"""
        SELECT RECORD_TIMESTAMP, HEART_RATE, OXYGEN_SATURATION, DEVICE_TYPE
        FROM CLINICAL_RECORDS_GOLD
        WHERE PATIENT_ID = {patient_id}
        ORDER BY RECORD_TIMESTAMP DESC
        LIMIT 100
    """
    results = conn.cursor().execute(query).fetchall()
    st.write("Latest Clinical Records:")
    st.dataframe(results)
