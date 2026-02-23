-- ============================================================
-- PHASE 3: BRONZE → SILVER → GOLD PIPELINE
-- Production-Ready Layered Architecture
-- ============================================================

-- ============================================================
-- 1️⃣ SILVER TABLE (Structured + Validated Layer)
-- ============================================================

CREATE OR REPLACE TABLE SILVER_IOT (
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


-- ============================================================
-- 2️⃣ STREAM ON BRONZE TABLE (CDC Tracking)
-- ============================================================

CREATE OR REPLACE STREAM BRONZE_STREAM 
ON TABLE BRONZE_IOT_RAW;


-- ============================================================
-- 3️⃣ TASK: BRONZE → SILVER (Transform + Validate)
-- ============================================================

CREATE OR REPLACE TASK BRONZE_TO_SILVER_TASK
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 * * * * UTC'  -- Runs hourly
AS

MERGE INTO SILVER_IOT tgt
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
    FROM BRONZE_STREAM
    WHERE METADATA$ACTION = 'INSERT'
      -- Data Quality Rules (Healthcare-safe ranges)
      AND RAW_VARIANT:heart_rate::NUMBER BETWEEN 30 AND 220
      AND RAW_VARIANT:oxygen_saturation::NUMBER BETWEEN 70 AND 100
) src
ON tgt.PATIENT_ID = src.PATIENT_ID
   AND tgt.RECORD_TIMESTAMP = src.RECORD_TIMESTAMP

WHEN MATCHED THEN UPDATE SET
    HEART_RATE = src.HEART_RATE,
    OXYGEN_SATURATION = src.OXYGEN_SATURATION,
    DEVICE_TYPE = src.DEVICE_TYPE,
    METADATA_FILENAME = src.METADATA_FILENAME,
    LOAD_TIMESTAMP = src.LOAD_TIMESTAMP

WHEN NOT MATCHED THEN INSERT (
    PATIENT_ID,
    DEVICE_ID,
    RECORD_TIMESTAMP,
    HEART_RATE,
    OXYGEN_SATURATION,
    DEVICE_TYPE,
    METADATA_FILENAME,
    LOAD_TIMESTAMP
) VALUES (
    src.PATIENT_ID,
    src.DEVICE_ID,
    src.RECORD_TIMESTAMP,
    src.HEART_RATE,
    src.OXYGEN_SATURATION,
    src.DEVICE_TYPE,
    src.METADATA_FILENAME,
    src.LOAD_TIMESTAMP
);


-- ============================================================
-- 4️⃣ STREAM ON SILVER (Incremental Propagation)
-- ============================================================

CREATE OR REPLACE STREAM SILVER_STREAM
ON TABLE SILVER_IOT;


-- ============================================================
-- 5️⃣ GOLD TABLE (Business-Optimized Layer)
-- ============================================================

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


-- ============================================================
-- 6️⃣ TASK: SILVER → GOLD (Business Layer Merge)
--    Chained After Bronze Task
-- ============================================================

CREATE OR REPLACE TASK SILVER_TO_GOLD_TASK
  WAREHOUSE = 'COMPUTE_WH'
  AFTER BRONZE_TO_SILVER_TASK
AS

MERGE INTO CLINICAL_RECORDS_GOLD tgt
USING (
    SELECT *
    FROM SILVER_STREAM
    WHERE METADATA$ACTION = 'INSERT'
     -- Possible options:
        --   METADATA$ACTION = 'INSERT'   -- Only new inserted rows
        --   METADATA$ACTION = 'DELETE'   -- Only deleted rows (if tracking deletes)
        --   METADATA$ISUPDATE = TRUE     -- Rows that are part of an update operation (if updates are tracked)
        --   METADATA$ROW_ID              -- Unique row identifier (for deduplication/advanced logic)

) src
ON tgt.PATIENT_ID = src.PATIENT_ID
   AND tgt.RECORD_TIMESTAMP = src.RECORD_TIMESTAMP

WHEN MATCHED THEN UPDATE SET
    HEART_RATE = src.HEART_RATE,
    OXYGEN_SATURATION = src.OXYGEN_SATURATION,
    DEVICE_TYPE = src.DEVICE_TYPE,
    METADATA_FILENAME = src.METADATA_FILENAME,
    LOAD_TIMESTAMP = src.LOAD_TIMESTAMP

WHEN NOT MATCHED THEN INSERT (
    PATIENT_ID,
    DEVICE_ID,
    RECORD_TIMESTAMP,
    HEART_RATE,
    OXYGEN_SATURATION,
    DEVICE_TYPE,
    METADATA_FILENAME,
    LOAD_TIMESTAMP
) VALUES (
    src.PATIENT_ID,
    src.DEVICE_ID,
    src.RECORD_TIMESTAMP,
    src.HEART_RATE,
    src.OXYGEN_SATURATION,
    src.DEVICE_TYPE,
    src.METADATA_FILENAME,
    src.LOAD_TIMESTAMP
);


-- ============================================================
-- 7️⃣ SECURITY GRANTS (Example RBAC Setup)
-- ============================================================

GRANT SELECT, INSERT, UPDATE ON TABLE SILVER_IOT TO ROLE TRANSFORM_ROLE;
GRANT SELECT, INSERT, UPDATE ON TABLE CLINICAL_RECORDS_GOLD TO ROLE TRANSFORM_ROLE;

GRANT USAGE ON STREAM BRONZE_STREAM TO ROLE TRANSFORM_ROLE;
GRANT USAGE ON STREAM SILVER_STREAM TO ROLE TRANSFORM_ROLE;

GRANT USAGE ON TASK BRONZE_TO_SILVER_TASK TO ROLE TRANSFORM_ROLE;
GRANT USAGE ON TASK SILVER_TO_GOLD_TASK TO ROLE TRANSFORM_ROLE;


-- ============================================================
-- 8️⃣ ACTIVATE TASKS
-- ============================================================

ALTER TASK BRONZE_TO_SILVER_TASK RESUME;
ALTER TASK SILVER_TO_GOLD_TASK RESUME;

-- ============================================================
-- END OF FILE
-- ============================================================