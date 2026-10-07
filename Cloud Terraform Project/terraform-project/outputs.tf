output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  description = "Subnet id => CIDR"
  value       = { for s in aws_subnet.public : s.id => s.cidr_block }
}

output "private_subnet_cidr" {
  value = aws_subnet.private.cidr_block
}

output "web_public_ips" {
  value = aws_instance.web[*].public_ip
}

output "web_urls" {
  value = [for ip in aws_instance.web[*].public_ip : "http://${ip}"]
}

output "site_bucket" {
  value = aws_s3_bucket.site.id
}

output "web_role_arn" {
  value = aws_iam_role.web.arn
}
