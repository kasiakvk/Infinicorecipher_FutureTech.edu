output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.galactic_code_vpc.id
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.galactic_code_db.endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name for assets"
  value       = aws_s3_bucket.galactic_code_assets.bucket
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.galactic_code_cdn.domain_name
}
