# Cost Optimization

-- Cost Optimization for Snowflake Data Warehouse

-- 1. Warehouse Scaling & Suspension
-- Schedule scaling and auto-suspend for warehouses based on usage patterns
CREATE OR REPLACE WAREHOUSE MEDALLION_PIPELINE_WH
  WITH WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = TRUE
  AUTO_RESUME = TRUE;

-- 2. Query Performance Monitoring
-- Use QUERY_HISTORY and ACCOUNT_USAGE views to identify slow or expensive queries
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY WHERE EXECUTION_TIME > 5000;
-- Optimize frequently used queries and add materialized views as needed

-- 3. Resource Monitors
-- Use resource monitors to alert and suspend warehouses when credit limits are reached
CREATE OR REPLACE RESOURCE MONITOR COST_MONITOR WITH CREDIT_QUOTA = 100 TRIGGER WHEN QUOTA = 90 ACTION SUSPEND;

-- 4. Storage Optimization
-- Use clustering, partitioning, and compression (Parquet) to reduce storage costs
-- Example: CLUSTER BY (PATIENT_ID, RECORD_TIMESTAMP) in Gold table

-- 5. Scheduling & Automation
-- Use tasks to automate scaling, suspension, and optimization routines
-- Example: CREATE OR REPLACE TASK COST_OPTIMIZATION_TASK ...

-- 6. Cost Reporting
-- Generate cost and usage reports for stakeholders
-- Example: SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY;

-- Example Workflow:
-- 1. Warehouses scale and suspend automatically
-- 2. Resource monitors alert and suspend on quota
-- 3. Query performance is monitored and optimized
-- 4. Storage is clustered and compressed
-- 5. Cost reports are generated for review
