# HIPAA-compliant
Implementing HIPAA-compliant **Row-Level Security (RLS)** in Snowflake is less about "locking a door" and more about "checking an ID card" every time a query is run. To do this, we use an **Entitlement Table** (the ID list) and a **Row Access Policy** (the security guard).

### Why this is HIPAA Compliant:

* **Need to Know:** Doctors only see records for patients in their direct care.
* **Auditability:** Every access attempt is logged in Snowflake's `ACCESS_HISTORY` view.
* **Separation of Duties:** The `SECURITYADMIN` manages the policy, while `DOCTORS` only consume the data.
* **No Data Leakage:** Secure Views prevent users from using "brute-force" SQL tricks to discover the distribution of patient IDs.

### Next Step

To further protect patient privacy, would you like me to show you how to apply **Dynamic Data Masking** to hide specific PII (like Social Security Numbers or Birthdates) for users who aren't authorized to see them?

# Dynamic Data Masking for HIPAA Compliance

This directory contains SQL scripts for implementing dynamic masking policies on sensitive columns in Snowflake healthcare data tables.

## Overview

- **Dynamic Data Masking:**
  - Redacts or partially hides sensitive PII (e.g., SSN, Date of Birth) unless the user has an authorized role.
  - Ensures doctors see clinical trends but not full PII unless permitted.

## Steps Implemented

1. **Create Masking Policies:**
   - SSN masking: Only last 4 digits visible to non-admins.
   - DOB masking: Only year of birth visible to non-admins.

2. **Apply Policies to Gold Layer Table:**
   - Masking policies are applied directly to the relevant columns.

## Governance Features

- **Row-Level Security:** Prevents doctors from seeing other doctors' patients.
- **Dynamic Masking:** Prevents unauthorized viewing of PII.
- **Secure Views:** Hides query logic and metadata.

## Architecture Checklist

- Storage Integration: Secure S3 connection.
- Snowpipe: Automated ingestion.
- Streams/Tasks: JSON to relational transformation.
- Clustering: Fast performance on PATIENT_ID.
- Security: RLS + Masking + Secure Views.

## Additional Notes

- Masking policies are flexible and can be extended to other columns.
- Only verified roles can see full PII.
- For audit and compliance, combine masking with alerting and access controls.