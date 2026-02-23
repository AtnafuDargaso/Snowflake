### Phase 3: The Silver & Gold Layers (Optimization)

This is where we turn "messy JSON" into "fast SQL."

6. **Streams & Tasks:** * A **Stream** sits on the Bronze table to track new rows.
* A **Task** runs every minute (if data exists) to transform and "Upsert" (Merge) data into the **Gold Table**.


7. **The Gold Table (Schema-on-Write):** This table is strictly structured.
* Promote fields like `PATIENT_ID`, `DEVICE_ID`, and `TIMESTAMP` to dedicated columns.
* **Clustering:** Apply `CLUSTER BY (PATIENT_ID, TIMESTAMP)`. This ensures that when a doctor searches for one patient, Snowflake ignores 99.9% of the other data.

Here is your **same one-file pipeline**, now rewritten with **clear, senior-level comments explaining how Streams and Tasks actually work**, especially around stream consumption and offsets in Snowflake.

This version is production-grade and documentation-ready.

---

# 📁 `phase_3_silver_gold_pipeline.sql` (Fully Commented for edu purpouse)

```sql
-- ============================================================
-- PHASE 3: BRONZE → SILVER → GOLD PIPELINE
-- Snowflake Medallion Architecture
-- ============================================================

-- IMPORTANT CONCEPT:
-- Streams DO update automatically.
-- They track row-level changes on the source table.
-- However, they DO NOT move data by themselves.
-- A Task (or query) must consume the stream.
-- When consumed successfully, the stream offset advances.
-- ============================================================



-- ============================================================
-- 1️⃣ SILVER TABLE (Structured + Validated Layer)
-- ============================================================
-- This table stores cleaned, typed, validated IoT records.
-- It is incrementally maintained via MERGE from the Bronze stream.
-- We cluster by (PATIENT_ID, RECORD_TIMESTAMP) for pruning
-- and optimized time-series access.

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
-- 2️⃣ STREAM ON BRONZE TABLE (Change Data Capture)
-- ============================================================
-- The stream tracks INSERT/UPDATE/DELETE changes
-- on BRONZE_IOT_RAW using Snowflake's table versioning.
--
-- It does NOT copy data.
-- It stores a pointer to changes since last consumption.
--
-- When queried inside a successful transaction,
-- the stream offset advances automatically.

CREATE OR REPLACE STREAM BRONZE_STREAM 
ON TABLE BRONZE_IOT_RAW;



-- ============================================================
-- 3️⃣ TASK: BRONZE → SILVER
-- ============================================================
-- This task:
--   • Runs on a schedule (hourly)
--   • Reads only NEW changes from BRONZE_STREAM
--   • Performs transformation + validation
--   • Uses MERGE for idempotent processing
--
-- If the task fails:
--   • Stream offset does NOT advance
--   • Changes remain available
--   • No data is lost
--
-- This provides exactly-once processing behavior.

CREATE OR REPLACE TASK BRONZE_TO_SILVER_TASK
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 * * * * UTC'  -- Runs hourly
AS

MERGE INTO SILVER_IOT tgt
USING (
    SELECT 
        -- Extract + Type Cast from semi-structured JSON
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
      -- Data Quality Enforcement (Healthcare validation)
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
-- This stream tracks changes applied to SILVER_IOT.
-- It enables clean separation of transformation logic.
--
-- Bronze handles ingestion.
-- Silver handles validation.
-- Gold handles business optimization.

CREATE OR REPLACE STREAM SILVER_STREAM
ON TABLE SILVER_IOT;



-- ============================================================
-- 5️⃣ GOLD TABLE (Analytics Optimized Layer)
-- ============================================================
-- Gold contains only business-ready records.
-- No semi-structured data.
-- Optimized for dashboard and BI workloads.

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
-- 6️⃣ TASK: SILVER → GOLD
-- ============================================================
-- This task runs AFTER the Bronze-to-Silver task.
-- It consumes only new Silver changes.
-- This prevents duplicated transformation logic.
--
-- Task chaining ensures deterministic execution order.

CREATE OR REPLACE TASK SILVER_TO_GOLD_TASK
  WAREHOUSE = 'COMPUTE_WH'
  AFTER BRONZE_TO_SILVER_TASK
AS

MERGE INTO CLINICAL_RECORDS_GOLD tgt
USING (
    SELECT *
    FROM SILVER_STREAM
    WHERE METADATA$ACTION = 'INSERT'
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
-- 7️⃣ RBAC (Role-Based Access Control)
-- ============================================================
-- Grants minimal privileges to transformation role.

GRANT SELECT, INSERT, UPDATE ON TABLE SILVER_IOT TO ROLE TRANSFORM_ROLE;
GRANT SELECT, INSERT, UPDATE ON TABLE CLINICAL_RECORDS_GOLD TO ROLE TRANSFORM_ROLE;

GRANT USAGE ON STREAM BRONZE_STREAM TO ROLE TRANSFORM_ROLE;
GRANT USAGE ON STREAM SILVER_STREAM TO ROLE TRANSFORM_ROLE;

GRANT USAGE ON TASK BRONZE_TO_SILVER_TASK TO ROLE TRANSFORM_ROLE;
GRANT USAGE ON TASK SILVER_TO_GOLD_TASK TO ROLE TRANSFORM_ROLE;



-- ============================================================
-- 8️⃣ ACTIVATE TASKS
-- ============================================================
-- Tasks are created in SUSPENDED state by default.
-- They must be resumed to begin execution.

ALTER TASK BRONZE_TO_SILVER_TASK RESUME;
ALTER TASK SILVER_TO_GOLD_TASK RESUME;


-- ============================================================
-- END OF FILE
-- ============================================================
```

---

# Clarity
✔ Streams track changes automatically
✔ Streams are consumed transactionally
✔ Offset advances only on success
✔ Tasks are the processing engine
✔ Validation happens in Silver
✔ Gold is purely analytics-optimized
✔ Exactly-once behavior achieved

