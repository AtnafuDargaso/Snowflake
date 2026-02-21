-- =============================================
-- Dynamic Data Masking for HIPAA Compliance
-- =============================================
-- This script implements dynamic masking policies for sensitive PII (SSN, DOB)
-- and applies them to the Gold Layer table. It also summarizes governance features.

-- =============================================
-- Step 1: Create Masking Policies
-- =============================================
-- Masking policies define how data is transformed at query time based on user role.

-- Masking for SSN: Only show the last 4 digits unless authorized
CREATE OR REPLACE MASKING POLICY GOVERNANCE.SSN_MASK AS (val string) 
  RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('PRIVACY_ADMIN', 'COMPLIANCE_OFFICER') THEN val
    ELSE '***-**-' || RIGHT(val, 4)
  END;

-- Masking for DOB: Only show the Year of Birth unless authorized
CREATE OR REPLACE MASKING POLICY GOVERNANCE.DOB_MASK AS (val date) 
  RETURNS date ->
  CASE
    WHEN CURRENT_ROLE() IN ('PRIVACY_ADMIN') THEN val
    ELSE DATE_FROM_PARTS(YEAR(val), 1, 1) -- Rounds to January 1st of birth year
  END;

-- =============================================
-- Step 2: Apply Policies to the Table
-- =============================================
-- Apply masking policies directly to PII columns in the Gold Layer table.

ALTER TABLE CLINICAL_RECORDS_GOLD 
  MODIFY COLUMN SOCIAL_SECURITY_NUMBER SET MASKING POLICY GOVERNANCE.SSN_MASK;

ALTER TABLE CLINICAL_RECORDS_GOLD 
  MODIFY COLUMN DATE_OF_BIRTH SET MASKING POLICY GOVERNANCE.DOB_MASK;

-- =============================================
-- Step 3: End-to-End Governance Summary
-- =============================================
-- Overview of implemented security features and their purposes.

-- | Security Feature      | Purpose                                      | Level           |
-- |----------------------|----------------------------------------------|-----------------|
-- | Row-Level Security   | Prevents Dr. A from seeing Dr. B's patients. | Horizontal      |
-- | Dynamic Masking      | Prevents unauthorized viewing of PII.         | Vertical        |
-- | Secure Views         | Hides logic and protects metadata.            | Architectural   |

-- =============================================
-- Step 4: Final Architecture Checklist
-- =============================================
-- Key architectural components for HIPAA compliance.

-- 1. Storage Integration: Secure S3 connection.
-- 2. Snowpipe: Automated ingestion.
-- 3. Streams/Tasks: Transformation from JSON (Bronze) to Relational (Gold).
-- 4. Clustering: Sub-5-second performance on PATIENT_ID.
-- 5. Security: RLS + Masking + Secure Views.

-- =============================================
-- End of Script
-- =============================================
