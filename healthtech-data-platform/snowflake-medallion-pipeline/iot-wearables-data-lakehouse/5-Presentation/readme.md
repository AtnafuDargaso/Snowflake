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