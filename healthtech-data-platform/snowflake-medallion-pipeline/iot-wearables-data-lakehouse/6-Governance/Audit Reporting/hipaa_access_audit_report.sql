-- =============================================
-- HIPAA Access Audit Query for PHI Monitoring
-- =============================================
-- This script generates a monthly audit report for PHI access via Secure Views.
-- It allows Compliance Officers to monitor who accessed patient records, what was viewed,
-- and the context of each query, supporting HIPAA compliance and zero-trust monitoring.

-- =============================================
-- Step 1: Monthly PHI Access Audit Report
-- =============================================
-- Joins ACCESS_HISTORY and QUERY_HISTORY to show:
--   - Access time
--   - Doctor username
--   - View accessed
--   - SQL executed
--   - Records viewed
--   - Compilation and execution times (for context)
-- Filters for accesses in the last month and orders by most recent access.

SELECT 
    query_start_time AS access_time,
    user_name AS doctor_username,
    direct_objects_accessed[0]:"objectName"::STRING AS view_accessed,
    query_text AS sql_executed,
    rows_produced AS records_viewed,
    compilation_time,
    execution_time
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY ah
JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh 
  ON ah.query_id = qh.query_id
WHERE view_accessed ILIKE '%V_PATIENT_VITALS%'
  AND access_time >= DATEADD('month', -1, CURRENT_TIMESTAMP())
ORDER BY access_time DESC;

-- =============================================
-- Step 2: Audit Best Practices
-- =============================================
-- Zero-Trust Monitoring: Proves Row-Level Security controls are working.
-- Data Retention: Snowflake keeps ACCOUNT_USAGE data for 365 days.
--   - For HIPAA records requiring longer retention (6–7 years), set up a Task to copy audit data to permanent storage monthly.
-- Unusual Volume: Investigate high records_viewed counts for possible bulk exports.

-- =============================================
-- Step 3: Final Implementation Checklist
-- =============================================
-- | Component      | Status      | Purpose                                      |
-- |---------------|-------------|----------------------------------------------|
-- | Ingestion     | ✅ Complete  | Wearable → S3 → Snowpipe → Bronze            |
-- | Processing    | ✅ Complete  | Streams & Tasks → Flattened Gold Table       |
-- | Performance   | ✅ Complete  | Clustering by PATIENT_ID for < 5s latency    |
-- | Security      | ✅ Complete  | Row-Level Security + Secure Views            |
-- | Privacy       | ✅ Complete  | Dynamic Masking on SSN/DOB                   |
-- | Governance    | ✅ Complete  | Real-time Abuse Alerts + Audit Reporting      |

-- =============================================
-- End of Script
-- =============================================
