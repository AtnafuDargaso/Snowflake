# AWS & Snowflake Storage Integration for Medallion Pipeline

This file documents the Terraform code and workflow for securely connecting your Snowflake account to your AWS S3 bucket for wearable data ingestion.

## 1. AWS Side: IAM Policy & Role

```hcl
resource "aws_iam_policy" "snowflake_s3_access" {
  name        = "SnowflakeS3WearableAccess"
  description = "Allows Snowflake to read/list wearable data in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::your-wearable-data-bucket",
          "arn:aws:s3:::your-wearable-data-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "snowflake_role" {
  name = "SnowflakeStorageIntegrationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = var.snowflake_iam_user_arn
      }
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.snowflake_external_id
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.snowflake_s3_access.arn
}
```

## 2. Snowflake Side: Storage Integration

```hcl
resource "snowflake_storage_integration" "s3_wearable_int" {
  name    = "S3_WEARABLE_INTEGRATION"
  comment = "Secure connection to wearable data bucket"
  type    = "EXTERNAL_STAGE"

  enabled          = true
  storage_provider = "S3"
  storage_aws_role_arn = aws_iam_role.snowflake_role.arn
  storage_allowed_locations = ["s3://your-wearable-data-bucket/raw/"]
}
```

## 3. The "Chicken and Egg" Workflow

1. **Snowflake** needs the **AWS Role ARN**.
2. **AWS** needs the **Snowflake IAM User & External ID** (which only exist *after* the integration is created).

**Standard Resolution:**
- Step A: Run `terraform apply` to create the Snowflake Integration with a placeholder Trust Policy in AWS.
- Step B: Retrieve the `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` from Snowflake.
- Step C: Update your Terraform variables with those IDs and run `apply` again to finalize the secure handshake.

---

### Final Implementation Checklist

| Component              | Status         | Responsibility         |
|-----------------------|---------------|-----------------------|
| **Snowflake Account** | ✅ Pre-existing| You                   |
| **S3 Bucket**         | ✅ Pre-existing| You                   |
| **IAM Policy/Role**   | 🛠️ Defined    | Terraform (AWS)       |
| **Storage Integration**| 🛠️ Defined    | Terraform (Snowflake) |
| **Trust Handshake**   | 🛠️ Step 3     | Manual/Terraform Cycle|

---

For External Stage and Snowpipe setup, see the next file or ask for a sample.
