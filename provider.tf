terraform {
  # Ensures the local engine binary supports the new native S3 native locking mechanism
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "s3-state-123"
    key          = "backend/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true # Native S3 locking (requires Terraform 1.10+)
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
