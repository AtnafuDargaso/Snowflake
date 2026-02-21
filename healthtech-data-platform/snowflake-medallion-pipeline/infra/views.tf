resource "snowflake_view" "doctor_dashboard" {
  database  = snowflake_database.clinical_db.name
  schema    = "PRESENTATION"
  name      = "V_PATIENT_VITALS"
  is_secure = true
  statement = <<-EOT
    SELECT PATIENT_ID, RECORD_TIMESTAMP, HEART_RATE
    FROM GOLD_CORE.PATIENT_VITALS
  EOT
}
