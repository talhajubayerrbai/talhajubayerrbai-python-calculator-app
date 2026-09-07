#!/usr/bin/env bash
###############################################################################
# bootstrap.sh — create the S3 bucket + DynamoDB table for Terraform state
#
# Run ONCE before the first `terraform init`.
# Idempotent — safe to re-run.
#
# Usage:
#   AWS_PROFILE=my-profile ./bootstrap.sh
#   # or with explicit region:
#   AWS_DEFAULT_REGION=us-east-1 ./bootstrap.sh
###############################################################################
set -euo pipefail

BUCKET="udap-calculator-tf-state-a7f3k9"
TABLE="udap-calculator-tf-lock"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "==> Bootstrapping Terraform state backend"
echo "    Bucket : $BUCKET"
echo "    Table  : $TABLE"
echo "    Region : $REGION"
echo ""

# ── S3 bucket ─────────────────────────────────────────────────────────────────
if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  echo "[skip] S3 bucket $BUCKET already exists."
else
  echo "[create] S3 bucket $BUCKET ..."
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$REGION"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi

  echo "[config] Enabling versioning ..."
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET" \
    --versioning-configuration Status=Enabled

  echo "[config] Enabling server-side encryption ..."
  aws s3api put-bucket-encryption \
    --bucket "$BUCKET" \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }]
    }'

  echo "[config] Blocking public access ..."
  aws s3api put-public-access-block \
    --bucket "$BUCKET" \
    --public-access-block-configuration \
      "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

  echo "[ok] Bucket created and hardened."
fi

# ── DynamoDB lock table ────────────────────────────────────────────────────────
if aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" 2>/dev/null; then
  echo "[skip] DynamoDB table $TABLE already exists."
else
  echo "[create] DynamoDB table $TABLE ..."
  aws dynamodb create-table \
    --table-name "$TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"

  echo "[wait] Waiting for table to become active ..."
  aws dynamodb wait table-exists --table-name "$TABLE" --region "$REGION"
  echo "[ok] Table created."
fi

echo ""
echo "==> Bootstrap complete. You can now run:"
echo "    cd infra && terraform init"
