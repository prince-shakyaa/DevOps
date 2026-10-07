variable "aws_region" {
  description = "Region the bucket is created in"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Bucket name - S3 names are global, so it must be unique across every account"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Use 3-63 lowercase letters, digits and hyphens, starting and ending with a letter or digit."
  }
}

variable "environment" {
  description = "Deployment stage, used as a tag"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "versioning_enabled" {
  description = "Keep every previous version of each object"
  type        = bool
  default     = true
}

variable "archive_after_days" {
  description = "Move objects under notices/ to STANDARD_IA after this many days"
  type        = number
  default     = 30
}

variable "use_localstack" {
  description = "true sends every call to LocalStack, false to real AWS"
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "LocalStack edge URL"
  type        = string
  default     = "http://localhost:4566"
}
