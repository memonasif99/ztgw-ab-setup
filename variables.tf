# ─────────────────────────────────────────────────────────────────────────────
# Global
# ─────────────────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short identifier used in all resource names"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to merge on every resource"
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────────────────────────────────────
# Network
# ─────────────────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "public_subnet_cidrs" {
  description = "CIDR blocks for the 2 public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly 2 public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the 4 private subnets (2 per AZ: app + gwlb-endpoint)"
  type        = list(string)
  default = [
    "10.0.11.0/24", # private-app-1  (AZ-a)
    "10.0.12.0/24", # private-app-2  (AZ-b)
    "10.0.21.0/24", # private-gwlb-1  (AZ-a)
    "10.0.22.0/24", # private-gwlb-2  (AZ-b)
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 4
    error_message = "Exactly 4 private subnet CIDRs are required."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Security
# ─────────────────────────────────────────────────────────────────────────────
variable "ssh_allowed_cidrs" {
  description = "CIDR ranges allowed to SSH into private EC2 instances (e.g. bastion or VPN)"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "bastion_ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH to the bastion host. Restrict to your IP in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ─────────────────────────────────────────────────────────────────────────────
# EC2
# ─────────────────────────────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type for NGINX servers"
  type        = string
  default     = "t3.micro"
}


# ─────────────────────────────────────────────────────────────────────────────
# GWLB Endpoints
# ─────────────────────────────────────────────────────────────────────────────
variable "gwlb_endpoint_service_name" {
  description = "VPC endpoint service name from the remote GWLB account (com.amazonaws.vpce.<region>.<svc-id>)"
  type        = string
}

# ─────────────────────────────────────────────────────────────────────────────
# ALB
# ─────────────────────────────────────────────────────────────────────────────
variable "enable_alb_deletion_protection" {
  description = "Prevent accidental ALB deletion; set true for staging and prod"
  type        = bool
  default     = false
}
