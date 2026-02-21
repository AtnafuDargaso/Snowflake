# Alerting & Automated Monitoring for HIPAA Compliance

This directory contains the SQL scripts to implement automated alerting and monitoring in Snowflake for HIPAA-compliant healthcare data platforms.

## Overview

- **Automated Monitoring & Alerting System:**
  - Detects unusual query activity (e.g., high volume from a single user) on sensitive views.
  - Sends email notifications to compliance officers when thresholds are exceeded.

## Steps Implemented

1. **Create Email Notification Integration:**
   - Securely connects Snowflake to your email system for alert delivery.
   - Only verified Snowflake users can be recipients.

2. **Define Alerting Logic:**
   - Monitors `SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY` for suspicious query volumes on the Secure View (`V_PATIENT_VITALS`).
   - Triggers alert if a user exceeds 50 queries in 5 minutes.

3. **Activate the Alert:**
   - Alerts are created in a suspended state by default.
   - Manual activation required to start monitoring.

## Governance Model Visualized

- **Ingestion:** Snowpipe loads raw data.
- **Structuring:** Tasks flatten JSON into clustered Gold tables.
- **Access Control:** Row-Level Security limits which rows a doctor sees.
- **Privacy:** Dynamic Masking hides PII (SSN, DOB) from non-admins.
- **Audit/Alerting:** Snowflake Alerts monitor query history for HIPAA-violating patterns.

## Final Summary Table

| Security Component      | HIPAA Requirement           | Implementation                        |
|------------------------|----------------------------|----------------------------------------|
| Data Encryption        | Safeguard PHI at rest/transit | Snowflake native AES-256 (Default)   |
| Access Control         | Minimum Necessary Standard  | Secure Views + Row Access Policy       |
| Privacy                | De-identification/Redaction | Dynamic Data Masking                   |
| Audit Controls         | Activity Monitoring         | Query History + Automated Alerts       |

## Additional Notes

- Alerts are cost-effective and only run when activated.
- You can customize query thresholds and recipients as needed.
- For compliance reporting, consider monthly audit queries to track data access.
