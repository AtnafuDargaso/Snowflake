# HIPAA Audit Reporting for PHI Access

This directory contains SQL scripts and guidance for generating monthly audit reports on Protected Health Information (PHI) access in Snowflake, supporting HIPAA compliance.

## Overview

- **Audit Query:**
  - Monitors who accessed PHI via the Secure View (`V_PATIENT_VITALS`).
  - Joins `ACCESS_HISTORY` and `QUERY_HISTORY` to show user, query, records viewed, and context.
  - Designed for Compliance Officers to detect potential policy violations or "data snooping".

## Steps Implemented

1. **Monthly PHI Access Audit Report:**
   - Shows access time, doctor username, view accessed, SQL executed, records viewed, compilation and execution times.
   - Filters for accesses in the last month.
   - Orders by most recent access.

2. **Audit Best Practices:**
   - Zero-Trust Monitoring: Proves Row-Level Security controls are working.
   - Data Retention: Snowflake keeps `ACCOUNT_USAGE` data for 365 days. For HIPAA, set up a Task to copy audit data to permanent storage monthly.
   - Unusual Volume: Investigate high `records_viewed` counts for possible bulk exports.

## Final Implementation Checklist

| Component      | Status      | Purpose                                      |
|---------------|-------------|----------------------------------------------|
| Ingestion     |  Complete  | Wearable → S3 → Snowpipe → Bronze            |
| Processing    |  Complete  | Streams & Tasks → Flattened Gold Table       |
| Performance   |  Complete  | Clustering by PATIENT_ID for < 5s latency    |
| Security      |  Complete  | Row-Level Security + Secure Views            |
| Privacy       |  Complete  | Dynamic Masking on SSN/DOB                   |
| Governance    |  Complete  | Real-time Abuse Alerts + Audit Reporting      |

## Additional Notes

- For HIPAA records requiring retention beyond 365 days, automate monthly archiving to "Cold Storage".
- Use audit reports to demonstrate compliance to regulators.
- Consider implementing purge scripts for data retention laws (e.g., 7-year deletion/archiving).
