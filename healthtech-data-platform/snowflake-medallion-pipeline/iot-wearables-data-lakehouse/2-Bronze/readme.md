### Phase 2: The Bronze Layer (Raw Ingestion)

The goal here is to get data into Snowflake as fast as possible with zero transformation.

4. **Cloud Storage Integration:** Create a **Storage Integration** in Snowflake to securely connect to your S3 bucket without embedding secret keys.
5. **Snowpipe:** Set up an **S3 Event Notification** (SQS) that triggers **Snowpipe**. As soon as a `.json` file hits S3, Snowpipe copies it into the **Bronze Table**.
* **Table Structure:** One `VARIANT` column for the JSON and one `METADATA$FILENAME` column for tracking.
* **Retention:** Set `DATA_RETENTION_TIME_IN_DAYS = 1` to save on storage costs.

