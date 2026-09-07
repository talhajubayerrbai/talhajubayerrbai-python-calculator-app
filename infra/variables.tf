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

variable "ssh_key_name" {
  description = "Name of an existing EC2 key pair to allow SSH access. Leave empty to skip key attachment."
  type        = string
  default     = ""
}
