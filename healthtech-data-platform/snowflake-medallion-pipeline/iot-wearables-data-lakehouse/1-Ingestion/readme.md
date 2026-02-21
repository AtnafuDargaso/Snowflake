### Phase 1: The Edge (Collection & Ingestion)

1. **Device to Gateway:** Wearable devices (e.g., heart rate monitors) send JSON packets via Bluetooth/Wi-Fi to a hospital gateway.
2. **Cloud Ingress:** The gateway pushes data to **AWS IoT Core** or an **Amazon Kinesis Data Firehose**.
3. **S3 Landing (The Data Lake):** Kinesis batches the JSON and writes it to an **S3 Bucket** (e.g., `s3://hospital-wearable-data/raw/`). Files are partitioned by date/hour for organizational efficiency.