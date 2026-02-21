# Snowflake Medallion Pipeline for IoT Wearables Data Lakehouse

## Overview
Enterprise-grade, HIPAA-compliant medallion architecture for ingesting, processing, securing, and governing IoT wearable health data. Modular, scalable, and follows best practices for data engineering, security, and compliance.

## Project Structure
- `snowflake-medallion-pipeline/`: Main pipeline code, SQL, and documentation.
- `infra/`: Terraform infrastructure for Snowflake, AWS, and CI/CD automation.
- `iot-wearables-data-lakehouse/`: Architecture diagrams, system design, modeling docs, data sharing scripts, and high availability setup.

## Quick Start
1. Review `infra/README.md` for infrastructure setup.
2. Deploy pipeline phases in order (see `snowflake-medallion-pipeline/README.md`).
3. Use phase-specific readme files for details.
4. For data sharing, see `7-DataSharing/readme.md` for instructions to securely share data with up to 1000 hospitals.
5. For high availability, see `8-HA/readme.md` and `phase8_ha_setup.sql` for multi-region, failover, and monitoring configuration.

## DevOps
- Automated CI/CD via GitHub Actions.
- Infrastructure as Code (Terraform).
- High availability and disaster recovery across US/EU regions (see Step 8).

## Security & Compliance
- Row-level security, dynamic masking, secure views, alerting, auditing, retention.
- Secure, scalable data sharing with external hospitals (see Step 7).
- High availability and automated failover for critical tables and warehouses (see Step 8).

## Contributing
See individual phase readme files or contact the maintainer for questions or contributions.
