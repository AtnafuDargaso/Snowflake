terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.90"
    }
  }
}

provider "snowflake" {
  role = "ACCOUNTADMIN"
}

resource "snowflake_database" "clinical_db" {
  name = "CLINICAL_DATA_DB"
}

resource "snowflake_schema" "gold" {
  database = snowflake_database.clinical_db.name
  name     = "GOLD_CORE"
}

resource "snowflake_schema" "governance" {
  database = snowflake_database.clinical_db.name
  name     = "GOVERNANCE"
}
