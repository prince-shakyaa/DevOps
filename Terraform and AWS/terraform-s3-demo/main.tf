# Bucket that stores the campus notice board files
resource "aws_s3_bucket" "notices" {
  bucket        = var.bucket_name
  force_destroy = true # allow destroy even when objects are still inside

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "notices" {
  bucket = aws_s3_bucket.notices.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Every object is encrypted at rest with S3-managed keys
resource "aws_s3_bucket_server_side_encryption_configuration" "notices" {
  bucket = aws_s3_bucket.notices.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Nothing in this bucket is ever meant to be public
resource "aws_s3_bucket_public_access_block" "notices" {
  bucket = aws_s3_bucket.notices.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Old notices move to the cheaper infrequent-access class,
# and superseded versions are dropped after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "notices" {
  bucket = aws_s3_bucket.notices.id

  rule {
    id     = "archive-old-notices"
    status = "Enabled"

    filter {
      prefix = "notices/"
    }

    transition {
      days          = var.archive_after_days
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  depends_on = [aws_s3_bucket_versioning.notices]
}

# A first object, uploaded by Terraform itself
resource "aws_s3_object" "welcome" {
  bucket       = aws_s3_bucket.notices.id
  key          = "notices/welcome.txt"
  content      = "Welcome to the ${var.environment} campus notice board.\n"
  content_type = "text/plain"
}
