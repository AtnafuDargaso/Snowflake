--  It prevents unauthorized users from seeing the underlying metadata or query plan, protecting PII (Personally Identifiable Information).
CREATE OR REPLACE SECURE VIEW DOCTOR_PATIENT_METRICS AS
SELECT 
    g.PATIENT_ID,
    g.RECORD_TIMESTAMP,
    g.HEART_RATE,
    g.OXYGEN_SATURATION
FROM CLINICAL_RECORDS_GOLD g
JOIN DOCTOR_ASSIGNMENTS a ON g.PATIENT_ID = a.PATIENT_ID
WHERE a.DOCTOR_EMAIL = CURRENT_USER(); -- Filters data based on who is logged in