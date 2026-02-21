### Phase 3: The Silver & Gold Layers (Optimization)

This is where we turn "messy JSON" into "fast SQL."

6. **Streams & Tasks:** * A **Stream** sits on the Bronze table to track new rows.
* A **Task** runs every minute (if data exists) to transform and "Upsert" (Merge) data into the **Gold Table**.


7. **The Gold Table (Schema-on-Write):** This table is strictly structured.
* Promote fields like `PATIENT_ID`, `DEVICE_ID`, and `TIMESTAMP` to dedicated columns.
* **Clustering:** Apply `CLUSTER BY (PATIENT_ID, TIMESTAMP)`. This ensures that when a doctor searches for one patient, Snowflake ignores 99.9% of the other data.