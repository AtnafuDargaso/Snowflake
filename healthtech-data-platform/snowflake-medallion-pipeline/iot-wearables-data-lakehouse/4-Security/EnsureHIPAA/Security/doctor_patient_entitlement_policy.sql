-- =============================================
-- Step 1: The Entitlement Table
-- =============================================
-- This table defines which doctor is allowed to see which patient.
-- It should be kept in a highly-restricted schema (e.g., GOVERNANCE).

CREATE OR REPLACE TABLE GOVERNANCE.DOCTOR_ENTITLEMENTS (
    DOCTOR_EMAIL VARCHAR(100),
    PATIENT_ID NUMBER(38,0),
    ACCESS_LEVEL VARCHAR(20) -- e.g., 'FULL', 'LIMITED'
);

-- Example: Dr. Smith can only see Patient 123
INSERT INTO GOVERNANCE.DOCTOR_ENTITLEMENTS (DOCTOR_EMAIL, PATIENT_ID, ACCESS_LEVEL)
VALUES ('drsmith@hospital.com', 123, 'FULL');

-- =============================================
-- Step 2: Create the Row Access Policy
-- =============================================
-- This policy acts as a gatekeeper. It returns TRUE if the doctor has access to the row,
-- or FALSE to hide it. Uses CURRENT_USER() to identify who is running the query.

CREATE OR REPLACE ROW ACCESS POLICY GOVERNANCE.PATIENT_DATA_POLICY
    AS (target_patient_id NUMBER) RETURNS BOOLEAN ->
       -- 1. Admins see everything
       CURRENT_ROLE() IN ('SYSADMIN', 'SECURITYADMIN', 'COMPLIANCE_OFFICER')
       OR 
       -- 2. Doctors see only their assigned patients via the mapping table
       EXISTS (
           SELECT 1 FROM GOVERNANCE.DOCTOR_ENTITLEMENTS
           WHERE DOCTOR_EMAIL = CURRENT_USER()
             AND PATIENT_ID = target_patient_id
       );

-- =============================================
-- Step 3: Apply the Policy to the Gold Table
-- =============================================
-- Attach the policy to the PATIENT_ID column of your production table.

ALTER TABLE CLINICAL_RECORDS_GOLD 
ADD ROW ACCESS POLICY GOVERNANCE.PATIENT_DATA_POLICY ON (PATIENT_ID);

-- =============================================
-- Step 4: The HIPAA Secure View
-- =============================================
-- To comply with HIPAA's "Minimum Necessary" rule, create a SECURE VIEW.
-- Secure Views hide underlying query logic and metadata from users.

CREATE OR REPLACE SECURE VIEW PRESENTATION.V_PATIENT_VITALS AS
SELECT 
    RECORD_TIMESTAMP,
    HEART_RATE,
    OXYGEN_SATURATION,
    DEVICE_TYPE
FROM CLINICAL_RECORDS_GOLD;
-- Note: PATIENT_ID is omitted to minimize exposure of PII.
-- Doctors already know who they are looking at.
