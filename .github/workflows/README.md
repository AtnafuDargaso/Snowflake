# CI/CD for Snowflake Infrastructure with GitHub Actions
Integrating the entire Snowflake infrastructure (tables, tasks, policies, and views) into a CI/CD pipeline ensures that your clinical data environment is always in sync with your code and fully audited.

This directory contains the GitHub Actions workflow for automating the deployment of your Snowflake infrastructure as code using Terraform.

## Prerequisites

Before running the workflow, add the following as **GitHub Actions Secrets** in your repository settings:
- `SNOWFLAKE_ACCOUNT`: Your account locator (e.g., `xy12345.us-east-1`).
- `SNOWFLAKE_USER`: The service account for Terraform.
- `SNOWFLAKE_PASSWORD`: The password for that account.
- `SNOWFLAKE_ROLE`: Typically `TERRAFORM_PROVISIONER` or `SYSADMIN`.

## Workflow Overview
- **Plan on Pull Requests:** Preview changes to Snowflake infrastructure before merging.
- **Apply on Main:** Automatically deploys changes to Snowflake when code is merged to `main`.
- **Formatting Check:** Ensures all Terraform code is clean and standardized.

## How to Use
1. Place your Terraform code in the `infra/` directory.
2. Add the provided `terraform.yml` workflow to `.github/workflows/`.
3. Push changes or open pull requests to trigger the workflow.

---

This setup ensures your Snowflake environment is always in sync with your codebase and fully auditable.
