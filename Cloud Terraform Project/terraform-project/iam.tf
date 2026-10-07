# The web servers read their page from S3 through a role, so no access keys
# are ever written onto the instance.
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "read_site" {
  statement {
    sid       = "ListSiteBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid       = "ReadSiteObjects"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/site/*"]
  }
}

resource "aws_iam_role" "web" {
  name               = "${local.name}-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy" "read_site" {
  name   = "read-site-content"
  role   = aws_iam_role.web.id
  policy = data.aws_iam_policy_document.read_site.json
}

resource "aws_iam_instance_profile" "web" {
  name = "${local.name}-web-profile"
  role = aws_iam_role.web.name
}
