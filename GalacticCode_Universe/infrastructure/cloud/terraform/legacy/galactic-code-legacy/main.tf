# Galactic Code AWS Infrastructure
# Educational Gaming Platform

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "GalacticCode"
      Environment = var.environment
      Owner       = "InfiniCoreCipher"
      Purpose     = "Educational-Gaming"
    }
  }
}

# VPC Configuration
resource "aws_vpc" "galactic_code_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "galactic-code-vpc-${var.environment}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "galactic_code_igw" {
  vpc_id = aws_vpc.galactic_code_vpc.id
  
  tags = {
    Name = "galactic-code-igw-${var.environment}"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.galactic_code_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "galactic-code-public-1-${var.environment}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.galactic_code_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "galactic-code-public-2-${var.environment}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.galactic_code_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name = "galactic-code-private-1-${var.environment}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.galactic_code_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  
  tags = {
    Name = "galactic-code-private-2-${var.environment}"
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "galactic_code_db_subnet_group" {
  name       = "galactic-code-db-subnet-group-${var.environment}"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  
  tags = {
    Name = "galactic-code-db-subnet-group-${var.environment}"
  }
}

# RDS PostgreSQL Database
resource "aws_db_instance" "galactic_code_db" {
  identifier     = "galactic-code-db-${var.environment}"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.db_instance_class
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  db_name  = "galacticcode"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.galactic_code_db_subnet_group.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = var.environment == "dev"
  
  tags = {
    Name = "galactic-code-db-${var.environment}"
  }
}

# S3 Bucket for Game Assets
resource "aws_s3_bucket" "galactic_code_assets" {
  bucket = "galactic-code-assets-${var.environment}-${random_string.bucket_suffix.result}"
  
  tags = {
    Name = "galactic-code-assets-${var.environment}"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "galactic_code_assets_versioning" {
  bucket = aws_s3_bucket.galactic_code_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "galactic_code_assets_encryption" {
  bucket = aws_s3_bucket.galactic_code_assets.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "galactic_code_cdn" {
  origin {
    domain_name = aws_s3_bucket.galactic_code_assets.bucket_regional_domain_name
    origin_id   = "S3-galactic-code-assets"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.galactic_code_oai.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-galactic-code-assets"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name = "galactic-code-cdn-${var.environment}"
  }
}

resource "aws_cloudfront_origin_access_identity" "galactic_code_oai" {
  comment = "OAI for Galactic Code assets"
}

# Security Groups
resource "aws_security_group" "rds_sg" {
  name_prefix = "galactic-code-rds-${var.environment}"
  vpc_id      = aws_vpc.galactic_code_vpc.id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.galactic_code_vpc.cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "galactic-code-rds-sg-${var.environment}"
  }
}
