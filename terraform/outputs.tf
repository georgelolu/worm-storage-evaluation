output "bucket_name" {
  description = "WORM S3 bucket name"
  value       = aws_s3_bucket.worm.id
}

output "bucket_arn" {
  description = "WORM S3 bucket ARN"
  value       = aws_s3_bucket.worm.arn
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "object_lock_status" {
  description = "Object Lock status"
  value       = aws_s3_bucket.worm.object_lock_enabled
}
