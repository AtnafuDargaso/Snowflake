# Wearable Device Data Ingestion (AWS/GCP/Azure to Snowflake)
## Project Overview
This project outlines the ingestion and storage strategy for migrating massive volumes of semi-structured JSON data from hospital wearable devices into Snowflake. The goal is to provide doctors with a searchable interface that delivers results in under 5 seconds while optimizing for storage cost-efficiency across billions of records.

## Problem Statement

We are migrating patient wearable device records to **Snowflake**. The source data is high-volume, semi-structured JSON.

Problem Statement
* **Scale**: Billions of rows of high-frequency wearable data.
* **Format**: Semi-structured JSON.
* **Performance**: Sub-5-second query latency for clinical staff.
* **Target:** Query response time  seconds for doctors.
* **Constraint:** Minimize storage costs for billions of rows while maintaining searchability. or Minimize storage overhead and compute costs associated with querying large-scale VARIANT data.


## Proposed Solution: The "Medallion" Pipeline

To balance performance and cost, we will implement a **Schema-on-Write** approach using a columnar format (Parquet) before ingestion.

### 1. High-Level Architecture

1. **Ingestion:** Wearable devices stream data to **AWS IoT Core** or directly to **Amazon Kinesis Data Streams**.
2. **Processing (The Cost-Saver):** Use **Amazon Data Firehose** to batch the streams.
* **Transformation:** Firehose triggers an AWS Lambda function to flatten the JSON and convert it to **Apache Parquet**.
* **Partitioning:** Data is partitioned by `hospital_id` and `event_date` to ensure doctors only scan the data they need.

3. **Storage:** The optimized Parquet files are stored in **Amazon S3** (Standard or Intelligent-Tiering).
4. **Warehouse Loading:** Snowflake's **Snowpipe** detects new files in S3 and automatically loads them into a **Cortex-searchable** or **Clustered** table.

---

## Technical Design & Optimization

### Storage Cost Reduction

* **Compression:** By converting JSON to Parquet, we achieve up to **3x–5x compression**. Since Snowflake charges based on compressed storage, this directly slashes your bill.
* **Pruning:** By using S3 prefixes (e.g., `s3://bucket/year=2024/month=05/`), Snowflake's external stages can ignore irrelevant data, reducing compute costs.

### Performance (The < 5s Goal)

To ensure doctors get instant results among billions of rows, we utilize:

* **Search Optimization Service (SOS):** In Snowflake, enable SOS on the wearable ID columns to speed up point lookups.
* **Materialized Views:** Pre-aggregate common metrics (like average heart rate per hour) so the dashboard doesn't have to calculate them on the fly.

### The Path to S3

The data reaches S3 via **Amazon Data Firehose**. It acts as the "buffer." Instead of sending every tiny JSON packet to S3 (which creates "small file problem" overhead), Firehose waits until it has 128MB of data or 5 minutes has passed, then writes a single, optimized file to your S3 bucket.

---

> **Note:** If the data contains PII (Personally Identifiable Information), ensure S3 buckets use **AES-256 encryption** and Snowflake is configured with **HIPAA-compliant** Business Critical editions.


