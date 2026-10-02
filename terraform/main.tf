resource "aws_s3_bucket" "worm" {
  bucket_prefix = "${var.project_name}-"

  object_lock_enabled = true

  tags = {
    Project     = var.project_name
    Environment = "lab"
    Purpose     = "WORM storage evaluation"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "worm" {
  bucket = aws_s3_bucket.worm.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "worm" {
  bucket = aws_s3_bucket.worm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "worm" {
  bucket = aws_s3_bucket.worm.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_object_lock_configuration" "worm" {
  bucket = aws_s3_bucket.worm.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.retention_days
    }
  }
}
