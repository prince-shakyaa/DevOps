# use_localstack = true points every service at the LocalStack container.
# With use_localstack = false the endpoint block disappears and the provider
# uses the normal AWS credential chain (env vars, ~/.aws, SSO, instance role).
provider "aws" {
  region = var.aws_region

  access_key                  = var.use_localstack ? "test" : null
  secret_key                  = var.use_localstack ? "test" : null
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  s3_use_path_style           = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      ec2 = var.localstack_endpoint
      iam = var.localstack_endpoint
      s3  = var.localstack_endpoint
      sts = var.localstack_endpoint
    }
  }

  default_tags {
    tags = local.common_tags
  }
}
