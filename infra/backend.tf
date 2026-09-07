###############################################################################
# backend.tf — remote state in S3; provider requirements
#
# Backend bucket, key and region are injected at `terraform init` time via
# -backend-config flags from the workflow. Do NOT hardcode them here.
# set_pipeline_account wrote:
#   secrets.TF_STATE_BUCKET — S3 bucket name
#   vars.TF_STATE_KEY       — S3 object key
#   vars.AWS_REGION         — AWS region
###############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Partial backend configuration: bucket/key/region supplied by -backend-config
  # flags in the CI workflow (infra.yml). This keeps credentials out of source.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = "calculator"
      ManagedBy  = "terraform"
      Repository = "talhajubayerrbai/talhajubayerrbai-python-calculator-app"
    }
  }
}

provider "tls" {}
