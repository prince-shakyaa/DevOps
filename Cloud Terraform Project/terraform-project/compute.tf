resource "aws_instance" "web" {
  count                  = var.web_instance_count
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % var.public_subnet_count].id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.web.name

  # rendered once per instance and run by cloud-init on first boot
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    bucket   = aws_s3_bucket.site.id
    region   = var.aws_region
    hostname = "${local.name}-web-${count.index + 1}"
  })
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
  }

  # IMDSv2 only. LocalStack does not store metadata options, so the block is
  # skipped there to avoid a permanent diff on every plan.
  dynamic "metadata_options" {
    for_each = var.use_localstack ? [] : [1]
    content {
      http_tokens = "required"
    }
  }

  tags = { Name = "${local.name}-web-${count.index + 1}" }

  # the page must exist in S3 before the instance boots and tries to fetch it
  depends_on = [aws_s3_object.index]
}
