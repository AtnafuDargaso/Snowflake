# 1. Row Access Policy: Doctor-Patient Boundary
resource "snowflake_row_access_policy" "patient_boundary" {
  database = snowflake_database.clinical_db.name
  schema   = snowflake_schema.governance.name
  name     = "PATIENT_DATA_POLICY"
  signature = {
    "target_patient_id" = "NUMBER"
  }
  body = <<-EOT
    CURRENT_ROLE() IN ('SYSADMIN', 'COMPLIANCE_OFFICER')
    OR EXISTS (
      SELECT 1 FROM GOVERNANCE.DOCTOR_ENTITLEMENTS
      WHERE DOCTOR_EMAIL = CURRENT_USER()
      AND PATIENT_ID = target_patient_id
    )
  EOT
}

# 2. Masking Policy: SSN Protection
resource "snowflake_masking_policy" "ssn_mask" {
  database        = snowflake_database.clinical_db.name
  schema          = snowflake_schema.governance.name
  name            = "SSN_MASK"
  value_data_type = "VARCHAR"
  body            = <<-EOT
    CASE
      WHEN CURRENT_ROLE() IN ('COMPLIANCE_OFFICER') THEN val
      ELSE '***-**-' || RIGHT(val, 4)
    END
  EOT
  return_data_type = "VARCHAR"
}
