resource "snowflake_stream_on_table" "bronze_stream" {
  database = snowflake_database.clinical_db.name
  schema   = "BRONZE_LANDING"
  name     = "WEARABLE_STREAM"
  table    = "RAW_JSON_DATA"
}

resource "snowflake_task" "flattening_task" {
  database  = snowflake_database.clinical_db.name
  schema    = snowflake_schema.gold.name
  name      = "FLATTEN_JSON_TASK"
  warehouse = "COMPUTE_WH"
  schedule  = "1 MINUTE"
  when          = "SYSTEM$STREAM_HAS_DATA('BRONZE_LANDING.WEARABLE_STREAM')"
  sql_statement = <<-EOT
    INSERT INTO GOLD_CORE.PATIENT_VITALS (PATIENT_ID, RECORD_TIMESTAMP, HEART_RATE)
    SELECT v:patient_id::int, v:ts::timestamp, v:hr::float
    FROM BRONZE_LANDING.WEARABLE_STREAM;
  EOT
  enabled       = true
}
