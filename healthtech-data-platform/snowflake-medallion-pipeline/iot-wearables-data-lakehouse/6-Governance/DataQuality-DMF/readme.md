Here is a **production-style Data Metric Function (DMF) setup** for a **Bronze → Silver → Gold** architecture in Snowflake. This is the kind of pattern you can mention in **Senior Data Engineer interviews**.

---

# Production DMF Setup (Bronze → Silver → Gold)

## Architecture Overview

| Layer            | Purpose                | DMF Focus                 |
| ---------------- | ---------------------- | ------------------------- |
| Bronze (Raw)     | Ingested data          | Freshness, Row Count      |
| Silver (Cleaned) | Validated/standardized | Nulls, Duplicates         |
| Gold (Business)  | Aggregated/metrics     | Business rules, anomalies |

---

# 1. Bronze Layer (Raw Ingestion Monitoring)

### Goal

Detect:

* Pipeline failures
* Late or missing loads

### Row Count Check

```sql
ALTER TABLE bronze.orders_raw
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
SCHEDULE = '15 MINUTE';
```

### Freshness Check

```sql
ALTER TABLE bronze.orders_raw
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.FRESHNESS
ON (ingestion_timestamp)
SCHEDULE = '15 MINUTE';
```

**What this catches**

* No new data arriving
* Stuck ingestion jobs

---

# 2. Silver Layer (Data Quality Checks)

### Null Check (Critical Column)

```sql
ALTER TABLE silver.orders
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
ON (customer_id)
SCHEDULE = '1 HOUR';
```

### Duplicate Check

```sql
ALTER TABLE silver.orders
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
ON (order_id)
SCHEDULE = '1 HOUR';
```

**What this catches**

* Bad transformations
* Upsert logic failures
* Data integrity issues

---

# 3. Gold Layer (Business Quality Monitoring)

### Row Count Trend (Anomaly Detection)

```sql
ALTER TABLE gold.daily_sales
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
SCHEDULE = '1 DAY';
```

### Custom Business Rule DMF

Example: Ensure no negative revenue

#### Create Custom DMF

```sql
CREATE OR REPLACE DATA METRIC FUNCTION no_negative_revenue(revenue NUMBER)
RETURNS NUMBER
AS
$$
SELECT COUNT_IF(revenue < 0)
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
$$;
```

#### Attach to Table

```sql
ALTER TABLE gold.daily_sales
ADD DATA METRIC FUNCTION no_negative_revenue
ON (total_revenue)
SCHEDULE = '1 DAY';
```

---

# 4. Monitoring Results

Query metric history:

```sql
SELECT
    TABLE_NAME,
    METRIC_NAME,
    VALUE,
    START_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_METRIC_HISTORY
WHERE TABLE_SCHEMA IN ('BRONZE','SILVER','GOLD')
ORDER BY START_TIME DESC;
```

---

# 5. Add Alert (Example)

Alert when duplicates appear:

```sql
CREATE OR REPLACE ALERT duplicate_orders_alert
WAREHOUSE = monitoring_wh
SCHEDULE = '1 HOUR'
IF (
    EXISTS (
        SELECT 1
        FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_METRIC_HISTORY
        WHERE TABLE_NAME = 'ORDERS'
          AND METRIC_NAME = 'DUPLICATE_COUNT'
          AND VALUE > 0
          AND START_TIME > DATEADD('hour', -1, CURRENT_TIMESTAMP())
    )
)
THEN
    CALL system$send_email(
        'data_alerts_integration',
        'data-team@company.com',
        'Duplicate orders detected',
        'Duplicates found in silver.orders'
    );
```

---

# How This Looks in Production

**Bronze**

* ROW_COUNT
* FRESHNESS

**Silver**

* NULL_COUNT (critical columns)
* DUPLICATE_COUNT (keys)

**Gold**

* Row count trends
* Custom business DMFs
* Alerts to Slack/Email

---

# DMF vs dbt vs Great Expectations (Interview Tip)

| Tool               | Best For                               |
| ------------------ | -------------------------------------- |
| DMF                | Continuous monitoring inside Snowflake |
| dbt tests          | Transformation-time validation         |
| Great Expectations | Complex external validation            |

**Strong answer**

> “I use dbt tests during transformation and Snowflake DMFs for continuous production monitoring and alerting.”

---

# Senior Data Engineer Talking Point

You can say:

> “I implemented Snowflake Data Metric Functions across Bronze, Silver, and Gold layers to monitor freshness, volume, nulls, duplicates, and business rules, with alerts triggered from DATA_METRIC_HISTORY to ensure pipeline reliability.”

---

If you want to go deeper, I can show:

* **End-to-end DMF architecture diagram**
* **Cost and performance considerations**
* **Common mistakes with DMF**
* **Real interview questions on Snowflake observability**.
