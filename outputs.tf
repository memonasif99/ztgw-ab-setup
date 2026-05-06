# ─────────────────────────────────────────────────────────────────────────────
# Network
# ─────────────────────────────────────────────────────────────────────────────
output "deployment_suffix" {
  description = "Random 5-char suffix appended to every resource name in this deployment"
  value       = local.suffix
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "public_subnet_ids" {
  description = "IDs of the 2 public subnets"
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of all 4 private subnets"
  value       = module.subnets.private_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the 2 private app-tier subnets (hosting EC2)"
  value       = module.subnets.private_app_subnet_ids
}

output "private_gwlb_subnet_ids" {
  description = "IDs of the 2 private ZTG GWLB endpoint subnets"
  value       = module.subnets.private_gwlb_subnet_ids
}

# ─────────────────────────────────────────────────────────────────────────────
# GWLB Endpoints
# ─────────────────────────────────────────────────────────────────────────────
output "gwlb_endpoint_ids" {
  description = "Map of AZ name → GWLB endpoint ID"
  value       = module.gwlb_endpoints.endpoint_ids
}

output "gwlb_endpoint_states" {
  description = "Map of AZ name → GWLB endpoint state (pendingAcceptance | available)"
  value       = module.gwlb_endpoints.endpoint_states
}

# ─────────────────────────────────────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────────────────────────────────────
output "alb_sg_id" {
  description = "Security Group ID attached to the ALB"
  value       = module.security_groups.alb_sg_id
}

output "ec2_sg_id" {
  description = "Security Group ID attached to EC2 instances"
  value       = module.security_groups.ec2_sg_id
}

# ─────────────────────────────────────────────────────────────────────────────
# ALB
# ─────────────────────────────────────────────────────────────────────────────
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the NGINX target group"
  value       = module.alb.target_group_arn
}

# ─────────────────────────────────────────────────────────────────────────────
# Bastion
# ─────────────────────────────────────────────────────────────────────────────
output "bastion_public_ip" {
  description = "Public IP of the bastion host — ssh -i ssh_key ubuntu@<ip>"
  value       = module.bastion.public_ip
}

output "bastion_instance_id" {
  description = "EC2 instance ID of the bastion host"
  value       = module.bastion.instance_id
}

output "key_pair_name" {
  description = "Name of the EC2 Key Pair registered in AWS"
  value       = module.ssh_key.key_name
}

output "ssh_private_key_path" {
  description = "Local path to the generated private key — use with: ssh -i <path> ubuntu@<host>"
  value       = module.ssh_key.private_key_path
}

# ─────────────────────────────────────────────────────────────────────────────
# EC2
# ─────────────────────────────────────────────────────────────────────────────
output "ec2_instance_ids" {
  description = "IDs of the 2 NGINX EC2 instances"
  value       = module.ec2.instance_ids
}

output "ec2_private_ips" {
  description = "Private IP addresses of the NGINX EC2 instances"
  value       = module.ec2.private_ips
}
