# terraform-state-bucket

This code sets up the AWS infrastructure needed to configure other infrastructure in an AWS account.

This code configures:
 * an S3 bucket to use for Terraform state files
 * a KMS key for S3 server-side encryption
 * an S3 bucket policy that ensures all access is via HTTPS
 * S3 Block Public Access

As this bucket doesn't pre-exist to store its own state file,
the Terraform backend configuration makes use of Terraform Cloud.
