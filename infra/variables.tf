###############################################################################
# variables.tf — input variables for the calculator-app infrastructure
###############################################################################

variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project identifier used as a name prefix for all resources."
  type        = string
  default     = "calculator"
}

variable "environment" {
  description = "Deployment environment label (dev / staging / prod)."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for the RKE2 node."
  type        = string
  default     = "t3.medium"
}

variable "github_repo" {
  description = "GitHub repository in <owner>/<repo> format. Used to scope the OIDC trust policy to this repo only."
  type        = string
  default     = "talhajubayerrbai/talhajubayerrbai-python-calculator-app"
}
