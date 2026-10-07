# terraform-s3-demo

A private S3 bucket for campus notices: versioned, encrypted with SSE-S3, all public access
blocked, and a lifecycle rule that moves `notices/` to `STANDARD_IA` and expires old versions.
The full walkthrough with screenshots is in the [parent README](../README.md).

## Resources

| Address | Purpose |
|---|---|
| `aws_s3_bucket.notices` | The bucket (`force_destroy = true`) |
| `aws_s3_bucket_versioning.notices` | Versioning on or suspended, from `versioning_enabled` |
| `aws_s3_bucket_server_side_encryption_configuration.notices` | AES256 default encryption |
| `aws_s3_bucket_public_access_block.notices` | All four public-access switches on |
| `aws_s3_bucket_lifecycle_configuration.notices` | `notices/` to STANDARD_IA after `archive_after_days`; noncurrent versions expire after 90 days |
| `aws_s3_object.welcome` | `notices/welcome.txt`, rendered with the environment name |

## Run it

Against LocalStack (as in the screenshots):

```bash
docker run -d --name devops-localstack -p 4566:4566 localstack/localstack:3.8
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

Against a real AWS account, set `use_localstack = false` in `terraform.tfvars`, pick a
bucket name nobody else has taken, and make sure credentials are available (`aws configure`,
SSO, or environment variables). Nothing else changes.

## Inputs

| Variable | Default | Notes |
|---|---|---|
| `bucket_name` | (required) | 3-63 chars, lowercase, digits, hyphens; checked by a `validation` block |
| `environment` | `dev` | Must be `dev`, `staging` or `prod` |
| `aws_region` | `ap-south-1` | |
| `versioning_enabled` | `true` | |
| `archive_after_days` | `30` | Days before `notices/` objects move to STANDARD_IA |
| `use_localstack` | `false` | `true` adds the LocalStack endpoints to the provider |
