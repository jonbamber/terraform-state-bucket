provider "aws" {}

terraform {
  backend "remote" {
    organization = "jonbamber"

    workspaces {
      name = "terraform-state-bucket"
    }
  }
}

data aws_iam_policy_document "state_bucket" {
  statement {
    sid       = "EnsureHTTPS"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.state_bucket.arn}/*"]
    actions   = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_kms_key" "state_bucket" {
  description = "KMS key for encryption on the Terraform state file bucket"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "jonbamber-tf-state"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.state_bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  policy = data.aws_iam_policy_document.state_bucket.json
}

resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket              = aws_s3_bucket.state_bucket.id
  block_public_acls   = true
  block_public_policy = true
}
