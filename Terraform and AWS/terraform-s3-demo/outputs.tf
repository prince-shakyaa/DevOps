output "bucket_name" {
  description = "Name of the bucket"
  value       = aws_s3_bucket.notices.id
}

output "bucket_arn" {
  description = "ARN, for use in IAM policies"
  value       = aws_s3_bucket.notices.arn
}

output "versioning_status" {
  value = aws_s3_bucket_versioning.notices.versioning_configuration[0].status
}

output "welcome_object_etag" {
  value = aws_s3_object.welcome.etag
}
