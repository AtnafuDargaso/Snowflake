-- Data Quality & Validation for CLINICAL_RECORDS_GOLD

-- 1. Constraints & Validation
-- Add NOT NULL and CHECK constraints to ensure data quality
ALTER TABLE CLINICAL_RECORDS_GOLD MODIFY COLUMN HEART_RATE SET NOT NULL;
ALTER TABLE CLINICAL_RECORDS_GOLD ADD CONSTRAINT CHECK_HEART_RATE CHECK (HEART_RATE > 0);

-- 2. Quarantine Bad Data
-- Move invalid records to quarantine table for review
CREATE OR REPLACE TABLE QUARANTINE_IOT_RAW AS SELECT * FROM BRONZE_IOT_RAW WHERE HEART_RATE <= 0;

-- 3. Automated Data Quality Checks
-- Use tasks to automate validation routines
-- Example: CREATE OR REPLACE TASK DATA_QUALITY_CHECK_TASK ...

-- 4. Monitoring & Reporting
-- Monitor data quality and generate reports
-- Example: SELECT COUNT(*) FROM QUARANTINE_IOT_RAW;

-- 5. Compliance & Audit
-- Ensure validation actions are logged and auditable
-- Example: Log validation in ACCOUNT_USAGE.ACCESS_HISTORY

-- Example Workflow:
-- 1. Constraints enforce data quality
-- 2. Bad data is quarantined
-- 3. Automated checks run regularly
-- 4. Data quality is monitored and audited
