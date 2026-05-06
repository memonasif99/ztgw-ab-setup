# ─────────────────────────────────────────────────────────────────────────────
# terraform.tfvars  —  Adjust values before running `terraform apply`
# ─────────────────────────────────────────────────────────────────────────────

aws_region   = "eu-west-3"
project_name = "ss-ztg-in"
environment  = "dev"

# ── Network ──────────────────────────────────────────────────────────────────
vpc_cidr           = "10.202.0.0/16"
# 2 public subnets — one per AZ
public_subnet_cidrs = ["10.202.1.0/24", "10.202.2.0/24"]

# 4 private subnets — 2 per AZ (app-tier first, ztg-gwlb-endpoint-tier second)
private_subnet_cidrs = [
  "10.202.11.0/24", # private-app-1  (eu-west-3a)
  "10.202.12.0/24", # private-app-2  (eu-west-3b)
  "10.202.21.0/24", # private-gwlb-1  (eu-west-3a)
  "10.202.22.0/24", # private-gwlb-2  (eu-west-3b)
]

# ── Security ─────────────────────────────────────────────────────────────────
# Restrict to your bastion host or VPN CIDR in production
ssh_allowed_cidrs = ["10.202.0.0/16"]

# Restrict to your public IP in production (e.g. ["203.0.113.5/32"])
bastion_ssh_allowed_cidrs = ["0.0.0.0/0"]

# ── EC2 ──────────────────────────────────────────────────────────────────────
instance_type   = "t3.micro"

# ── GWLB Endpoints ───────────────────────────────────────────────────────────
# Endpoint service name from the remote AWS account hosting the GWLB
gwlb_endpoint_service_name = "com.amazonaws.vpce.eu-west-3.<name>"

# ── ALB ──────────────────────────────────────────────────────────────────────
enable_alb_deletion_protection = false

# ── Extra tags ───────────────────────────────────────────────────────────────
tags = {
  Owner       = ""
}
