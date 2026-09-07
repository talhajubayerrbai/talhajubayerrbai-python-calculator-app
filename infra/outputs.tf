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
  description = "Full ECR repository URL for the calculator-app image (e.g. <account>.dkr.ecr.us-east-1.amazonaws.com/calculator-app)."
  value       = aws_ecr_repository.calculator.repository_url
}

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
