resource "snowflake_table" "vitals_gold" {
  database = snowflake_database.clinical_db.name
  schema   = snowflake_schema.gold.name
  name     = "PATIENT_VITALS"

  column {
    name     = "PATIENT_ID"
    type     = "NUMBER(38,0)"
    nullable = false
  }

  column {
    name     = "RECORD_TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
  }

  column {
    name = "HEART_RATE"
    type = "NUMBER(5,2)"
  }

  column {
    name = "SSN"
    type = "VARCHAR"
  }

  cluster_by = ["PATIENT_ID", "RECORD_TIMESTAMP"]
}
