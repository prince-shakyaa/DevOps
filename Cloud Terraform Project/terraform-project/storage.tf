# S3 names are global; a random suffix keeps re-runs from colliding
resource "random_id" "bucket_suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "site" {
  bucket        = "${local.name}-site-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "site/index.html"
  content_type = "text/html"
  content = templatefile("${path.module}/site/index.html", {
    environment = var.environment
    project     = var.project
  })
}
