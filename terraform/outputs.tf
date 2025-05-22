output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_url" {
  description = "URL of the created S3 bucket"
  value       = "https://${aws_s3_bucket.main.id}.s3.${var.aws_region}.amazonaws.com"
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.main.region
}

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = var.enable_versioning
}

output "bucket_tags" {
  description = "Tags applied to the bucket"
  value       = local.bucket_tags
}