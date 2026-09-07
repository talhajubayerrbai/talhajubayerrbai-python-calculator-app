###############################################################################
# backend.tf — remote state in S3 + DynamoDB locking
#
# The S3 bucket and DynamoDB table must exist BEFORE running `terraform init`.
# Bootstrap once manually or via the bootstrap script in this directory.
#
# Bucket : udap-calculator-tf-state-a7f3k9   (us-east-1, versioning enabled)
# Table  : udap-calculator-tf-lock           (PAY_PER_REQUEST, LockID PK)
###############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket         = "udap-calculator-tf-state-a7f3k9"
    key            = "calculator-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "udap-calculator-tf-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "calculator"
      ManagedBy   = "terraform"
      Repository  = "talhajubayerrbai/python-calculator-app"
    }
  }
}
