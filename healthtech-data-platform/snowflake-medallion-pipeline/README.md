# Snowflake Medallion Pipeline for IoT Wearables Data Lakehouse

## Overview
This repository implements a production-grade, HIPAA-compliant medallion architecture in Snowflake for ingesting, processing, securing, and governing IoT wearable health data. The pipeline is modular, scalable, and follows best practices for data engineering, security, and compliance.

## Architecture Phases

### 1. Ingestion (Edge)
- **Purpose:** Collect raw JSON data from IoT devices and land it in S3.
- **Key Artifacts:**
  - External stage for S3
  - JSON file format
  - Privilege grants
- **File:** `1-Ingestion/phase1_ingestion_setup.sql`

### 2. Bronze Layer (Raw Ingestion)
- **Purpose:** Load raw JSON from S3 into Snowflake with minimal transformation.
- **Key Artifacts:**
  - Bronze table (VARIANT column, metadata, 1-day retention)
  - Snowpipe for automated ingestion
  - Privilege grants
- **File:** `2-Bronze/phase2_bronze_setup.sql`

### 3. Silver & Gold Layers (Optimization)
- **Purpose:** Transform and upsert raw data into structured, query-optimized tables.
- **Key Artifacts:**
  - Silver table (flattened, semi-structured)
  - Stream for change tracking
  - Gold table (strict schema, clustering)
  - Task for automated upsert
  - Privilege grants
- **File:** `3-SilverOrGold/phase3_silver_gold_setup.sql`

### 4. Security & Privacy (HIPAA)
- **Purpose:** Enforce access control, data masking, and secure views for compliance.
- **Key Artifacts:**
  - Row-level security (doctor-patient entitlements)
  - Dynamic data masking (SSN, DOB)
  - Secure views (hide logic/metadata)
- **Files:**
  - `4-Security/EnsureHIPAA/Security/doctor_patient_entitlement_policy.sql`
  - `4-Security/EnsureHIPAA/Privacy/dynamic_data_masking_policy.sql`
  - `4-Security/SecureView/secure_view.sql`

### 5. Presentation
- **Purpose:** Expose only necessary, de-identified data to end users.
- **Artifacts:**
  - Secure views for analytics and reporting
- **File:** `5-Presentation/readme.md`

### 6. Governance (Alerting, Auditing, Retention)
- **Purpose:** Monitor, audit, and manage data lifecycle for compliance.
- **Key Artifacts:**
  - Automated alerting for suspicious access
  - Audit reporting for PHI access
  - Automated data retention and purge
- **Files:**
  - `6-Governance/Alerting_to_Maintain_HIPPA_Compliant/automated_monitoring_alert.sql`
  - `6-Governance/Audit Reporting/hipaa_access_audit_report.sql`
  - `6-Governance/Data Retention/automated_data_retention_policy.sql`

## Coding & Naming Standards
- **SQL Objects:** UPPER_SNAKE_CASE (e.g., BRONZE_IOT_RAW, CLINICAL_RECORDS_GOLD)
- **SQL Files:** lower_snake_case, phase and layer in filename (e.g., phase2_bronze_setup.sql)
- **Comments:** Each file and section is clearly commented with purpose and usage.
- **Privileges:** Explicit, role-based grants for all objects.
- **Idempotency:** All DDL uses CREATE OR REPLACE for safe, repeatable deployment.
- **Separation of Concerns:** Each phase/file is focused on a single layer or function.

## Security & Compliance
- **Row-Level Security:** Doctor-patient entitlements restrict data access.
- **Dynamic Masking:** PII is masked for non-privileged users.
- **Secure Views:** Hide query logic and metadata.
- **Alerting:** Automated monitoring for abnormal access patterns.
- **Auditing:** Monthly PHI access reports for compliance.
- **Retention:** Automated purge of data older than 7 years.

## How to Use
1. Deploy each phase in order, starting with ingestion and progressing to governance.
2. Review and adjust storage integration, S3 paths, and role names as needed for your environment.
3. Use the provided readme.md files in each directory for detailed phase-specific instructions.

## Diagram & Documentation
- See `ArchitectureDiagram.png`, `DataModeling.png`, and `SystemDesign.md` for visual and design references.

<<<<<<< HEAD
=======
End-to-End Solution Summary
You now have a fully operational, enterprise-grade architecture:

Data Layer: Automated ingestion to optimized, clustered tables.

Security Layer: HIPAA-compliant Row-Level Security and Masking.

Governance Layer: Automated purging and compliance alerting.

DevOps Layer: Infrastructure as Code (Terraform) with automated CI/CD.

>>>>>>> 69469f5 (feat(infra): add Terraform infrastructure and GitHub Actions CI/CD)
---

For questions or contributions, please refer to the individual phase readme files or contact the project maintainer.
