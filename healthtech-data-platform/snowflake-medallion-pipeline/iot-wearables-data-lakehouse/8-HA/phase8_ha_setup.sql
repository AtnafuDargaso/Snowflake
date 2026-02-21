-- Phase 8: High Availability (HA) Setup
-- This script configures high availability and disaster recovery for the medallion pipeline.

-- 1. Multi-Cluster Warehouse for Automatic Failover
CREATE OR REPLACE WAREHOUSE MEDALLION_PIPELINE_WH
  WITH WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = TRUE
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  MAX_CLUSTER_COUNT = 3
  MIN_CLUSTER_COUNT = 1
  SCALING_POLICY = 'STANDARD';

-- 2. Cross-Region Replication for Critical Tables
-- Example: Replicate Gold table to another region/account
ALTER TABLE CLINICAL_RECORDS_GOLD ENABLE REPLICATION TO ACCOUNTS = ('US_ACCOUNT', 'EU_ACCOUNT');

-- 3. Automated Failover
-- Example: Set failover for Gold table
ALTER TABLE CLINICAL_RECORDS_GOLD ENABLE FAILOVER;

-- 4. Monitoring and Alerting
-- Use tasks and alerts to monitor warehouse and region health
-- Example: Create task for health check
CREATE OR REPLACE TASK HA_HEALTH_CHECK_TASK
  WAREHOUSE = 'MEDALLION_PIPELINE_WH'
  SCHEDULE = 'USING CRON 0 * * * * UTC' -- Runs every hour
AS
SELECT CURRENT_TIMESTAMP AS CHECK_TIME,
       SYSTEM$WH_STATUS('MEDALLION_PIPELINE_WH') AS WAREHOUSE_STATUS,
       SYSTEM$DATABASE_STATUS('CLINICAL_RECORDS_GOLD') AS TABLE_STATUS;

-- Example: Alerting for failover or downtime
-- Use Snowflake's notification integration (email/webhook) or external monitoring tools
-- Pseudo-SQL for alerting:
-- CREATE OR REPLACE TASK HA_ALERT_TASK ...
-- Integrate with automated monitoring in 6-Governance/Alerting_to_Maintain_HIPPA_Compliant/automated_monitoring_alert.sql

-- 5. Document recovery procedures in readme.md

-- End of HA setup
