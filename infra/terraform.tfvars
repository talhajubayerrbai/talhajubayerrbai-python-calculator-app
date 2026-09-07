###############################################################################
# terraform.tfvars — default values for the calculator-app dev environment
# Override per-environment via -var-file= or environment variables (TF_VAR_*)
###############################################################################

aws_region    = "us-east-1"
project       = "calculator"
environment   = "dev"
instance_type = "t3.medium"
github_repo   = "talhajubayerrbai/talhajubayerrbai-python-calculator-app"
