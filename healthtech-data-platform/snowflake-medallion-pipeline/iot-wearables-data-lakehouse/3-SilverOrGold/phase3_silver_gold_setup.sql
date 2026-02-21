-- =============================================
-- Phase 3: The Silver & Gold Layers (Optimization)
-- =============================================
-- This script transforms raw JSON from the Bronze layer into structured, query-optimized tables.
-- Streams and Tasks automate the transformation and upsert process into the Gold table.

-- Step 1: Create the Silver Table (Flattened, Semi-Structured)
CREATE OR REPLACE TABLE SILVER_IOT_FLATTENED AS
SELECT 
    RAW_VARIANT:patient_id::NUMBER AS PATIENT_ID,
    RAW_VARIANT:device_id::STRING AS DEVICE_ID,
    RAW_VARIANT:timestamp::TIMESTAMP_NTZ AS RECORD_TIMESTAMP,
    RAW_VARIANT:heart_rate::NUMBER AS HEART_RATE,
    RAW_VARIANT:oxygen_saturation::NUMBER AS OXYGEN_SATURATION,
    RAW_VARIANT:device_type::STRING AS DEVICE_TYPE,
    METADATA_FILENAME,
    LOAD_TIMESTAMP
FROM BRONZE_IOT_RAW;

-- Step 2: Create a Stream on the Bronze Table to Track New Rows
CREATE OR REPLACE STREAM BRONZE_TO_SILVER_STREAM ON TABLE BRONZE_IOT_RAW;

-- Step 3: Create the Gold Table (Strictly Structured, Optimized)
CREATE OR REPLACE TABLE CLINICAL_RECORDS_GOLD (
    PATIENT_ID NUMBER,
    DEVICE_ID STRING,
    RECORD_TIMESTAMP TIMESTAMP_NTZ,
    HEART_RATE NUMBER,
    OXYGEN_SATURATION NUMBER,
    DEVICE_TYPE STRING,
    METADATA_FILENAME STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ
)
CLUSTER BY (PATIENT_ID, RECORD_TIMESTAMP);

-- Step 4: Create a Task to Transform and Upsert Data from Bronze to Gold
CREATE OR REPLACE TASK BRONZE_TO_GOLD_UPSERT_TASK
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 * * * * UTC' -- Runs every hour; adjust as needed
AS
MERGE INTO CLINICAL_RECORDS_GOLD tgt
USING (
    SELECT 
        RAW_VARIANT:patient_id::NUMBER AS PATIENT_ID,
        RAW_VARIANT:device_id::STRING AS DEVICE_ID,
        RAW_VARIANT:timestamp::TIMESTAMP_NTZ AS RECORD_TIMESTAMP,
        RAW_VARIANT:heart_rate::NUMBER AS HEART_RATE,
        RAW_VARIANT:oxygen_saturation::NUMBER AS OXYGEN_SATURATION,
        RAW_VARIANT:device_type::STRING AS DEVICE_TYPE,
        METADATA_FILENAME,
        LOAD_TIMESTAMP
    FROM BRONZE_TO_SILVER_STREAM
    WHERE METADATA$ACTION = 'INSERT' -- Use standard metadata column for inserts
) src
ON tgt.PATIENT_ID = src.PATIENT_ID AND tgt.RECORD_TIMESTAMP = src.RECORD_TIMESTAMP
WHEN MATCHED THEN UPDATE SET
    tgt.HEART_RATE = src.HEART_RATE,
    tgt.OXYGEN_SATURATION = src.OXYGEN_SATURATION,
    tgt.DEVICE_TYPE = src.DEVICE_TYPE,
    tgt.METADATA_FILENAME = src.METADATA_FILENAME,
    tgt.LOAD_TIMESTAMP = src.LOAD_TIMESTAMP
WHEN NOT MATCHED THEN INSERT (
    PATIENT_ID, DEVICE_ID, RECORD_TIMESTAMP, HEART_RATE, OXYGEN_SATURATION, DEVICE_TYPE, METADATA_FILENAME, LOAD_TIMESTAMP
) VALUES (
    src.PATIENT_ID, src.DEVICE_ID, src.RECORD_TIMESTAMP, src.HEART_RATE, src.OXYGEN_SATURATION, src.DEVICE_TYPE, src.METADATA_FILENAME, src.LOAD_TIMESTAMP
);

-- Step 5: Grant Required Privileges (example for role-based access)
GRANT INSERT, SELECT, UPDATE ON TABLE CLINICAL_RECORDS_GOLD TO ROLE TRANSFORM_ROLE;
GRANT USAGE ON STREAM BRONZE_TO_SILVER_STREAM TO ROLE TRANSFORM_ROLE;
GRANT USAGE ON TASK BRONZE_TO_GOLD_UPSERT_TASK TO ROLE TRANSFORM_ROLE;

-- =============================================
-- End of Phase 3 Silver & Gold Layer Setup
-- =============================================
