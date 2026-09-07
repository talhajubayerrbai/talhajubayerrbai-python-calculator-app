###############################################################################
# outputs.tf — values surfaced after terraform apply
###############################################################################

output "ec2_public_ip" {
  description = "Public IP address of the RKE2 EC2 node."
  value       = aws_instance.rke2.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (use as the app's HTTP endpoint)."
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "Full ECR repository URL for the calculator-app image."
  value       = aws_ecr_repository.calculator.repository_url
}

output "aws_role_arn" {
  description = "IAM role ARN that GitHub Actions assumes via OIDC to push to ECR and describe EC2."
  value       = aws_iam_role.github_actions.arn
}

output "ec2_key_pair_name" {
  description = "Name of the EC2 key pair registered in AWS."
  value       = aws_key_pair.ec2.key_name
}

output "ec2_private_key_pem" {
  description = "PEM-encoded RSA private key for SSH access to the EC2 instance. Sensitive — never logged."
  value       = tls_private_key.ec2.private_key_pem
  sensitive   = true
}

# ---- supplementary outputs ----

output "ecr_repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.calculator.arn
}

output "vpc_id" {
  description = "ID of the VPC created for the calculator app."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the ALB target group (HTTP:30080)."
  value       = aws_lb_target_group.app.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider registered in this AWS account."
  value       = aws_iam_openid_connect_provider.github.arn
}
