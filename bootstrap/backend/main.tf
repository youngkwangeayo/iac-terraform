#########################################
#  Terraform Backend Bootstrap (main.tf)
#########################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# ----------------------------
# 1. S3 Bucket for Terraform State
# ----------------------------
resource "aws_s3_bucket" "tf_state" {
  bucket = "nextpay-terraform-state"

  tags = {
    Name        = "nextpay-terraform-state"
    OwnerTeam   = "devops"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# S3 버전 관리
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 암호화 설정 (KMS)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = "alias/aws/s3"
    }
    bucket_key_enabled = true
  }
}

# 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 라이프사이클 정책 (선택)
resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "move-old-versions-to-glacier"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }
  }
}

# ----------------------------
# 2. DynamoDB Table for Terraform Lock
# ----------------------------
resource "aws_dynamodb_table" "tf_lock" {
  name         = "nextpay-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "nextpay-terraform-locks"
    OwnerTeam   = "devops"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}
