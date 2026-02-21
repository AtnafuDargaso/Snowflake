# Backup & Disaster Recovery

- Schedule regular backups and test restore procedures.
- Document RTO (Recovery Time Objective) and RPO (Recovery Point Objective).

## Example Backup
-- Backup & Disaster Recovery for CLINICAL_RECORDS_GOLD

-- 1. Scheduled Backups
-- Use Snowflake's Time Travel and Failover features for regular backups
ALTER TABLE CLINICAL_RECORDS_GOLD ENABLE FAILOVER;
-- Example: Schedule backup using tasks or external orchestration
-- CREATE OR REPLACE TASK BACKUP_TASK ...

-- 2. Restore Procedures
-- Document restore steps in readme.md
-- Example: Use Time Travel to restore dropped or modified data
-- SELECT * FROM CLINICAL_RECORDS_GOLD AT (TIMESTAMP => '2026-02-20T00:00:00Z');

-- 3. RTO/RPO Targets
-- Document Recovery Time Objective (RTO) and Recovery Point Objective (RPO)
-- Example: RTO = 1 hour, RPO = 15 minutes

-- 4. Cross-Region Replication
-- Enable replication to another region/account for disaster recovery
ALTER TABLE CLINICAL_RECORDS_GOLD ENABLE REPLICATION TO ACCOUNTS = ('US_ACCOUNT', 'EU_ACCOUNT');

-- 5. Monitoring & Alerting
-- Integrate with monitoring scripts to alert on backup failures or restore events
-- Example: Reference HA_HEALTH_CHECK_TASK and automated_monitoring_alert.sql

-- 6. Compliance & Audit
-- Ensure backup and restore procedures are logged and auditable
-- Example: Log all backup/restore actions in ACCOUNT_USAGE.ACCESS_HISTORY

-- Example Workflow:
-- 1. Schedule regular backups using Time Travel and Failover
-- 2. Monitor backup status and alert on failures
-- 3. Restore data as needed using Time Travel or replication
-- 4. Document and audit all actions for compliance
