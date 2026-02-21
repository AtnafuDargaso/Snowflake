-- =============================================
-- Phase 1: The Edge (Collection & Ingestion)
-- =============================================
-- This script sets up the external stage and Snowpipe for ingesting raw JSON data
-- from S3 into Snowflake for IoT wearable devices. No transformation or storage table here.

-- Step 1: Create an External Stage for S3 Raw Data
CREATE OR REPLACE STAGE RAW_IOT_STAGE
  URL = 's3://hospital-wearable-data/raw/'
  STORAGE_INTEGRATION = my_s3_integration; -- Replace with your storage integration name

-- Step 2: Create a File Format for JSON
CREATE OR REPLACE FILE FORMAT JSON_FORMAT
  TYPE = 'JSON';

-- Step 3: Grant Required Privileges (example for role-based access)
GRANT USAGE ON STAGE RAW_IOT_STAGE TO ROLE INGESTION_ROLE;

-- =============================================
-- End of Phase 1 Ingestion Setup
-- =============================================
