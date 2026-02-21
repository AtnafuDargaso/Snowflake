# Infrastructure as Code (IaC) for Snowflake Medallion Pipeline

This directory contains modular Terraform (or OpenTofu) scripts to deploy your entire HIPAA-compliant Snowflake data platform, including database, schemas, tables, security policies, automation, and secure views.

Why deploy with Terraform?
Disaster Recovery: You can rebuild your entire HIPAA environment in a new Snowflake account in minutes.
Audit Trail: Every change to your security policies is tracked in Git.
Consistency: Prevents human error in manually typing complex SQL policies.


## Structure

- **main.tf**: Provider, database, and schema setup
- **tables.tf**: Gold table definition with clustering
- **security.tf**: Row access and masking policies
- **automation.tf**: Streams and tasks for ETL automation
- **views.tf**: Secure presentation layer views
- **variables.tf**: (Optional) Input variables for modularity
- **outputs.tf**: (Optional) Useful outputs (e.g., table/view names)

## Usage

1. Install Terraform or OpenTofu and the Snowflake provider.
2. Configure your Snowflake credentials (see provider block in `main.tf`).
3. Run `terraform init`, `terraform plan`, and `terraform apply` to deploy.
4. All resources are version-controlled and reproducible for disaster recovery and audit.

---

Each `.tf` file is modular and can be extended for additional tables, policies, or automation as your platform grows.
