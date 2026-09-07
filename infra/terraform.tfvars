###############################################################################
# terraform.tfvars — default values for the calculator-app dev environment
# Override per-environment via -var-file= or environment variables (TF_VAR_*)
###############################################################################

aws_region    = "us-east-1"
project       = "calculator"
environment   = "dev"
instance_type = "t3.medium"

# ssh_key_name — set to an existing EC2 key pair name to enable SSH,
# or leave empty to rely on SSM Session Manager only.
ssh_key_name = ""
