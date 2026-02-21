# Day Zero Setup for Snowflake Medallion Pipeline

This file documents the manual steps required before Terraform and CI/CD can fully automate your Snowflake medical data platform deployment.

## 1. Manual "Day Zero" Setup

Before Terraform can take over, you (as the `ACCOUNTADMIN`) must create a **Service Account**. Terraform uses this account to talk to Snowflake so you don't have to use your personal login.

```sql
-- Run these as ACCOUNTADMIN in the Snowflake UI
CREATE ROLE TERRAFORM_PROVISIONER;
GRANT ROLE TERRAFORM_PROVISIONER TO USER YOUR_NAME;

-- Give the role power to create the objects in the TF script
GRANT CREATE DATABASE ON ACCOUNT TO ROLE TERRAFORM_PROVISIONER;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE TERRAFORM_PROVISIONER;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE TERRAFORM_PROVISIONER;
```

## 2. Cloud Storage Link (S3/Azure/GCS)

Snowflake needs permission to read the wearable data from your cloud provider. This is the only part that usually requires a "back-and-forth" between Snowflake and your Cloud Console (AWS/Azure).

1. **In Terraform:** You define a `snowflake_storage_integration`.
2. **In AWS:** You create an IAM Role that allows Snowflake to "AssumeRole" and read the S3 bucket.
3. **The Handshake:** You provide the Snowflake `STORAGE_AWS_IAM_USER_ARN` to your AWS IAM Role's trust policy.

## 3. The Full Component Map

| Component                | Status           | Managed By         |
|-------------------------|------------------|--------------------|
| **Snowflake Account**   | Already Deployed | You (Sign-up)      |
| **Cloud Storage (S3)**  | Already Deployed | You (AWS/Azure)    |
| **Service User/Role**   | Manual Setup     | You (One-time SQL) |
| **Database & Schemas**  | New              | Terraform          |
| **Clustered Gold Tables**| New              | Terraform          |
| **Masking/Row Policies**| New              | Terraform          |
| **Ingestion Tasks**     | New              | Terraform          |

---

### Summary

If you are starting with a brand-new Snowflake account today, you would:

1. Log in and run the **Service Account SQL** (Step 1 above).
2. Plug that service account's credentials into your **GitHub Secrets**.
3. Run the **GitHub Action** we created.
4. **Result:** Your entire hospital data platform is live and ready for wearable data.

---

For AWS IAM policy and Snowflake Storage Integration code, see the next file or ask for a sample.
