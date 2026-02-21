-- Phase 7: Data Sharing with 1000 Hospitals
-- This script automates secure data sharing with external hospital accounts using Snowflake Secure Data Sharing.
-- Adjust the list of hospital accounts as needed.

-- Example: Create a share and add consumers (hospitals)
CREATE OR REPLACE SHARE HOSPITAL_DATA_SHARE;

-- Grant access to the Gold table
GRANT SELECT ON TABLE CLINICAL_RECORDS_GOLD TO SHARE HOSPITAL_DATA_SHARE;

-- Add 1000 hospital accounts
-- The following Python script generates the SQL statement to add all accounts dynamically:
-- generate_hospital_accounts_sql.py

-- num_hospitals = 1000
-- account_prefix = "HOSPITAL"
-- account_suffix = "ACCOUNT"

-- accounts = [f"'{account_prefix}{i+1}.{account_suffix}'" for i in range(num_hospitals)]
-- accounts_str = ", ".join(accounts)

-- sql = f"ALTER SHARE HOSPITAL_DATA_SHARE ADD ACCOUNTS = ({accounts_str});"

-- with open("add_1000_hospital_accounts.sql", "w") as f:
--     f.write(sql)

-- print("SQL statement written to add_1000_hospital_accounts.sql")

-- Documented in readme.md
