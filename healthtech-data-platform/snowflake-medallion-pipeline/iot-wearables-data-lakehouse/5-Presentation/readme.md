### Summary of the Flow

| Step | Component | Action | Tech Used |
| --- | --- | --- | --- |
| **1** | **Ingestion** | Wearable → S3 | AWS IoT / Kinesis |
| **2** | **Bronze** | S3 → Snowflake | Snowpipe (Auto-ingest) |
| **3** | **Silver/Gold** | Flatten & Cluster | Streams, Tasks, Clustering Keys |
| **4** | **Security** | Row-Level Access | Secure Views + Entitlement Tables |
| **5** | **Presentation** | Sub-5s Query | Streamlit / Clinical App |


### Final Cost/Performance Check

* **Cost:** By flattening JSON into the Gold layer, you reduce storage by up to **60%** due to Snowflake’s columnar compression.
* **Performance:** The **Clustering Key** on `PATIENT_ID` reduces a "Full Table Scan" (minutes) to a "Partition Pruned Scan" (milliseconds).


# Streamlit Clinical App Example

This folder demonstrates how to build a clinical dashboard using Streamlit to query Snowflake and present sub-5s results to end users.

## Requirements
- Python 3.8+
- streamlit
- snowflake-connector-python

## Example Streamlit App: `clinical_dashboard.py`

```python
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
```

## How to Run
1. Install dependencies:
   ```bash
   pip install streamlit snowflake-connector-python
   ```
2. Update credentials in `clinical_dashboard.py`.
3. Run the app:
   ```bash
   streamlit run clinical_dashboard.py
   ```

## Notes
- This app demonstrates sub-5s query performance for clinical staff.
- You can extend the dashboard with charts, filters, and additional metrics.