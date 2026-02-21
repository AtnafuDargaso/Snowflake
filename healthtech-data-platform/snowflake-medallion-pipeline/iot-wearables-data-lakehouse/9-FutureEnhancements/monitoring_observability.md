# Monitoring & Observability

- Integrate with Datadog, Splunk, AWS CloudWatch, or Snowflake's native monitoring.
- Example: Use Snowflake tasks for health checks and alerting.
- Reference: See 8-HA/phase8_ha_setup.sql and 6-Governance/Alerting_to_Maintain_HIPPA_Compliant/automated_monitoring_alert.sql.

## Sample Health Check Query
SELECT CURRENT_TIMESTAMP, SYSTEM$WH_STATUS('MEDALLION_PIPELINE_WH');

## Dashboard
- Set up dashboards for pipeline health, latency, and throughput.
