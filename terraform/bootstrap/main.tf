terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# Tạo S3 Bucket để lưu State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "smartshop-tf-state-19092002" # ĐỔI TÊN Ở ĐÂY
}

# Bật tính năng Versioning để có thể rollback nếu lỡ tay làm hỏng state
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Tạo DynamoDB Table để làm State Lock
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "smartshop-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}