-- =============================================
-- Automated Monitoring & Alerting System for HIPAA Compliance
-- =============================================
-- This script implements Snowflake alerting to monitor query activity on sensitive views
-- and notifies compliance officers of suspicious access patterns.

-- =============================================
-- Step 1: Create Email Notification Integration
-- =============================================
-- Establishes a secure link between Snowflake and your email system.
-- Must be created by an ACCOUNTADMIN. Only verified Snowflake users can be recipients.

CREATE OR REPLACE NOTIFICATION INTEGRATION CLINICAL_COMPLIANCE_EMAIL
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('compliance_officer@hospital.com');

-- =============================================
-- Step 2: Define the Alerting Logic
-- =============================================
-- Creates an Alert object that checks query history for users exceeding a safety threshold.
-- Monitors the Secure View (V_PATIENT_VITALS) for more than 50 queries in a 5-minute window.

CREATE OR REPLACE ALERT MONITOR_VIEW_ABUSE
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = '5 MINUTE'
  IF (EXISTS (
      SELECT USER_NAME, COUNT(*) as query_count
      FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
      WHERE QUERY_TEXT ILIKE '%V_PATIENT_VITALS%'
        AND START_TIME >= DATEADD('minute', -5, CURRENT_TIMESTAMP())
        AND EXECUTION_STATUS = 'SUCCESS'
      GROUP BY USER_NAME
      HAVING COUNT(*) > 50
  ))
  THEN CALL SYSTEM$SEND_EMAIL(
    'CLINICAL_COMPLIANCE_EMAIL',
    'compliance_officer@hospital.com',
    'SECURITY ALERT: High Query Volume on Clinical View',
    'Suspicious activity detected. A user has exceeded 50 queries on the V_PATIENT_VITALS view in the last 5 minutes. Please review Access History.'
  );

-- =============================================
-- Step 3: Activate the Alert
-- =============================================
-- Alerts are created in a SUSPENDED state by default. Manually start the alert to enable monitoring.

ALTER ALERT MONITOR_VIEW_ABUSE RESUME;

-- =============================================
-- End of Script
-- =============================================
