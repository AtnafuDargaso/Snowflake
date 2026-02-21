-- =============================================
-- Phase 2: The Bronze Layer (Raw Ingestion)
-- =============================================
-- This script sets up the Bronze Layer in Snowflake for fast, raw ingestion of IoT wearable data.
-- Data is loaded as-is from S3 using Snowpipe, with minimal transformation and short retention.

-- Step 1: Create the Bronze Table for Raw JSON Data
CREATE OR REPLACE TABLE BRONZE_IOT_RAW (
    RAW_VARIANT VARIANT,
    METADATA_FILENAME STRING,
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
DATA_RETENTION_TIME_IN_DAYS = 1;

-- Step 2: Create a Snowpipe to Ingest Data from S3 to Bronze Table
CREATE OR REPLACE PIPE BRONZE_IOT_RAW_PIPE AS
  COPY INTO BRONZE_IOT_RAW (RAW_VARIANT, METADATA_FILENAME)
  FROM (
    SELECT $1, METADATA$FILENAME
    FROM @RAW_IOT_STAGE (FILE_FORMAT => JSON_FORMAT)
  )
  ON_ERROR = 'CONTINUE';

-- Step 3: Grant Required Privileges (example for role-based access)
GRANT INSERT ON TABLE BRONZE_IOT_RAW TO ROLE INGESTION_ROLE;
GRANT USAGE ON PIPE BRONZE_IOT_RAW_PIPE TO ROLE INGESTION_ROLE;

-- =============================================
-- End of Phase 2 Bronze Layer Setup
-- =============================================
