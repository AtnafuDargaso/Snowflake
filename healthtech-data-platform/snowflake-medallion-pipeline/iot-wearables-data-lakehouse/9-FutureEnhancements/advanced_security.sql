# Advanced Security

- Implement fine-grained access control (RBAC, ABAC).
- Enable audit logging for all access and changes.
- Use key management services (KMS) for encryption.

## Example RBAC
GRANT SELECT ON TABLE CLINICAL_RECORDS_GOLD TO ROLE DOCTOR_ROLE;
GRANT SELECT ON TABLE CLINICAL_RECORDS_GOLD TO ROLE AUDITOR_ROLE;

## Audit Logging
-- Snowflake automatically logs access; use ACCOUNT_USAGE views for reporting.
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY WHERE OBJECT_NAME = 'CLINICAL_RECORDS_GOLD';

## Encryption
-- Document KMS integration and encryption-at-rest.

-- Advanced Security for CLINICAL_RECORDS_GOLD

-- 1. Fine-Grained Access Control (Role-Based Access Control RBAC)
-- Only doctors and auditors can access the Gold table
GRANT SELECT ON TABLE CLINICAL_RECORDS_GOLD TO ROLE DOCTOR_ROLE;
GRANT SELECT ON TABLE CLINICAL_RECORDS_GOLD TO ROLE AUDITOR_ROLE;

-- 2. Attribute-Based Access Control (ABAC)
-- Example: Row-level security policy (see doctor_patient_entitlement_policy.sql)
-- CREATE OR REPLACE ROW ACCESS POLICY DOCTOR_PATIENT_POLICY ...

-- 3. Audit Logging
-- Query access history for compliance and investigations
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY WHERE OBJECT_NAME = 'CLINICAL_RECORDS_GOLD';

-- 4. Encryption
-- All data is encrypted at rest and in transit by default
-- Document KMS integration for key management and rotation
-- Example: AWS KMS, Azure Key Vault, GCP KMS

-- 5. Data Masking & Privacy
-- Dynamic masking for sensitive fields (see dynamic_data_masking_policy.sql)
-- Example: Mask SSN/DOB for non-privileged users

-- 6. Secure Views
-- Hide query logic and metadata (see secure_view.sql)
-- Example: CREATE SECURE VIEW ...

-- 7. Compliance Monitoring
-- Automated alerting for abnormal access (see automated_monitoring_alert.sql)
-- Example: CREATE TASK ...

-- Example Workflow:
-- 1. Doctor logs in (DOCTOR_ROLE), queries Gold table
-- 2. Auditor logs in (AUDITOR_ROLE), queries Gold table (may see masked data)
-- 3. All access is logged in ACCOUNT_USAGE.ACCESS_HISTORY
-- 4. Sensitive fields masked for non-privileged users
-- 5. Data encrypted at rest and in transit
-- 6. Alerts triggered for abnormal access
