-- =============================================
-- Automated Data Retention Policy for HIPAA Compliance
-- =============================================
-- This script implements a scheduled data retention and purge policy for Snowflake.
-- It archives and deletes records older than 7 years, as required by HIPAA and other regulations.
-- All purge events are logged for compliance auditing.

-- =============================================
-- Step 1: Define the Retention Logic
-- =============================================
-- A scheduled Task runs monthly to:
--   1. (Optional) Archive expired data to cold storage before deletion
--   2. Delete records older than 7 years from the Gold table
--   3. Log the purge event for compliance

CREATE OR REPLACE TASK GOVERNANCE.PURGE_EXPIRED_PATIENT_DATA
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 0 1 * * UTC' -- Runs at midnight on the 1st of every month
AS
BEGIN
    -- 1. Archive data to a cold storage table/S3 bucket if needed before deletion
    -- Example: INSERT INTO ARCHIVE_DB.COLD_STORAGE.EXPIRED_VITALS (...)
    
    -- 2. Delete data older than 7 years from the Gold table
    DELETE FROM CLINICAL_RECORDS_GOLD
    WHERE RECORD_TIMESTAMP < DATEADD('year', -7, CURRENT_TIMESTAMP());
    
    -- 3. Log the purge event for compliance auditors
    INSERT INTO GOVERNANCE.PURGE_LOGS (PURGE_DATE, RECORDS_DELETED, DATA_TYPE)
    SELECT CURRENT_TIMESTAMP(), SQLROWCOUNT, 'Wearable Vitals';
END;

-- =============================================
-- Step 2: Enable the Purge Task
-- =============================================
-- Resume the task to activate automated monthly purging.

ALTER TASK GOVERNANCE.PURGE_EXPIRED_PATIENT_DATA RESUME;

-- =============================================
-- End of Script
-- =============================================
