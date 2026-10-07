variable "aws_region" {
  description = "Region for every resource"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Name prefix for all resources"
  type        = string
  default     = "campus-portal"
}

variable "environment" {
  description = "dev, staging or prod"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "Address range of the VPC"
  type        = string
  default     = "10.40.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_count" {
  description = "How many public subnets to spread across availability zones"
  type        = number
  default     = 2
}

variable "web_instance_count" {
  description = "Number of web servers, placed round-robin over the public subnets"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 size for the web servers"
  type        = string
  default     = "t3.micro"
}

variable "admin_cidr" {
  description = "The only address range allowed to SSH in"
  type        = string
  default     = "198.51.100.24/32"
}

variable "localstack_ami_id" {
  description = "AMI used when running on LocalStack (real AWS looks up Ubuntu instead)"
  type        = string
  default     = "ami-1e749f67"
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
