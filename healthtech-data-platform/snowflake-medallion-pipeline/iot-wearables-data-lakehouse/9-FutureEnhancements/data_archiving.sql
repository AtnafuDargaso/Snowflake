# Data Archiving

- Implement automated archiving for historical data.
- Use lower-cost storage tiers for archived data.

## Example Archiving

-- Data Archiving for CLINICAL_RECORDS_GOLD

-- 1. Automated Archiving
-- Move historical data to archive table based on retention policy
CREATE OR REPLACE TABLE ARCHIVE_CLINICAL_RECORDS AS
SELECT * FROM CLINICAL_RECORDS_GOLD WHERE RECORD_TIMESTAMP < DATEADD(year, -7, CURRENT_DATE());

-- 2. Lower-Cost Storage Tier
-- Move archive table to lower-cost storage tier if supported
-- Example: Use Snowflake's storage tiering features

-- 3. Retention Policy
-- Document and enforce retention policy for compliance
-- Example: Data older than 7 years is archived

-- 4. Monitoring & Reporting
-- Monitor archiving process and generate reports
-- Example: SELECT COUNT(*) FROM ARCHIVE_CLINICAL_RECORDS;

-- 5. Compliance & Audit
-- Ensure archiving actions are logged and auditable
-- Example: Log archiving in ACCOUNT_USAGE.ACCESS_HISTORY

-- Example Workflow:
-- 1. Historical data is moved to archive table
-- 2. Archive table is stored in lower-cost tier
-- 3. Retention policy is enforced
-- 4. Archiving is monitored and audited
