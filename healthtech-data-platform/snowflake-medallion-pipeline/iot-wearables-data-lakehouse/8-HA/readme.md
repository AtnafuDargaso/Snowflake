# Phase 8: High Availability (HA)

This phase implements high availability and disaster recovery strategies for the medallion pipeline, ensuring continuous operation and minimal downtime across regions.

## Key Steps
- Deploy pipeline components redundantly across multiple AWS/GCP/Azure regions.
- Use Snowflake multi-cluster warehouses for automatic failover and load balancing.
- Enable cross-region replication for critical tables and shares.
- Automate failover and recovery using Terraform and CI/CD workflows.
- Monitor health and status of all regions, triggering alerts and automated remediation.

## Usage
1. Review `phase8_ha_setup.sql` for HA configuration steps.
2. Deploy using Terraform scripts and CI/CD workflows.
3. Monitor and test failover regularly.

## Notes
- Ensure all regions are compliant with local regulations.
- Document recovery procedures and RTO/RPO targets.


# Snowflake Single-Region Architecture

Within one cloud region (e.g., AWS us-east-1):

Snowflake automatically provides:

 Compute High Availability

Warehouses use multiple nodes
If one node fails → Snowflake replaces it
Queries retry automatically

 Storage High Availability

Data stored in cloud object storage
Replicated across multiple availability zones (AZs)
11 9’s durability (via cloud provider)

 Services Layer HA

Cloud services layer is redundant
Metadata highly available
So yes — Snowflake is HA within a region by design.

You do NOT configure it manually.