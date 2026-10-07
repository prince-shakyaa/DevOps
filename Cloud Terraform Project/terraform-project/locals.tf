locals {
  name = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = "parv-mehta"
    ManagedBy   = "terraform"
  }

  # first N availability zones of the region
  azs = slice(data.aws_availability_zones.available.names, 0, var.public_subnet_count)

  # real AWS: newest Ubuntu 24.04 from Canonical; LocalStack: a fixed emulated AMI
  ami_id = var.use_localstack ? var.localstack_ami_id : data.aws_ami.ubuntu[0].id
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  count       = var.use_localstack ? 0 : 1
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}
