# terraform-aws-infra

Modular Terraform project that provisions a production-grade AWS topology
with a VPC, public/private subnets across 2 AZs, an internet-facing ALB,
and 2 Ubuntu/NGINX EC2 instances in private subnets.

---

## Architecture Topology

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│  IGW (+ IGW Route Table — edge association)                     │
│                           VPC: 10.0.0.0/16                      │
│  ┌──────────────────────┐    ┌──────────────────────┐           │
│  │  Public Subnet 1     │    │  Public Subnet 2     │           │
│  │  10.0.1.0/24  AZ-a   │    │  10.0.2.0/24  AZ-b   │           │
│  │                      │    │                      │           │
│  │   ┌──────────────────┴────┴──────────────────┐   │           │
│  │   │         ALB  (internet-facing)           │   │           │
│  │   └──────────────────┬────┬──────────────────┘   │           │
│  └──────────────────────┘    └──────────────────────┘           │
│            │  Public Route Table → 0.0.0.0/0 → IGW              │
│            │                                                     │
│  ┌─────────▼────────────┐    ┌──────────────────────┐           │
│  │  Private Subnet 1    │    │  Private Subnet 2    │           │
│  │  (app) 10.0.11.0/24  │    │  (app) 10.0.12.0/24  │           │
│  │  AZ-a                │    │  AZ-b                │           │
│  │  ┌────────────────┐  │    │  ┌────────────────┐  │           │
│  │  │ EC2: NGINX #1  │  │    │  │ EC2: NGINX #2  │  │           │
│  │  │ (Ubuntu 22.04) │  │    │  │ (Ubuntu 22.04) │  │           │
│  │  └────────────────┘  │    │  └────────────────┘  │           │
│  │  Private RT-1        │    │  Private RT-2        │           │
│  └──────────────────────┘    └──────────────────────┘           │
│                                                                  │
│  ┌──────────────────────┐    ┌──────────────────────┐           │
│  │  Private Subnet 3    │    │  Private Subnet 4    │           │
│  │  (db) 10.0.21.0/24   │    │  (db) 10.0.22.0/24   │           │
│  │  AZ-a  [reserved]    │    │  AZ-b  [reserved]    │           │
│  │  Private RT-3        │    │  Private RT-4        │           │
│  └──────────────────────┘    └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

### Route Tables

| Route Table      | Association              | Routes                    |
|------------------|--------------------------|---------------------------|
| `igw-rt`         | IGW (edge association)   | local                     |
| `public-rt`      | public-subnet-1, 2       | 0.0.0.0/0 → IGW, local    |
| `private-rt-1`   | private-subnet-1 (app-a) | local                     |
| `private-rt-2`   | private-subnet-2 (app-b) | local                     |
| `private-rt-3`   | private-subnet-3 (db-a)  | local                     |
| `private-rt-4`   | private-subnet-4 (db-b)  | local                     |

> **NAT Gateway** — not included by default. To add internet egress for
> private instances (e.g., apt-get), provision NAT Gateways in the public
> subnets and uncomment the `route` block in `modules/routing/main.tf`.

---

## Module Structure

```
terraform-aws-infra/
├── providers.tf          # AWS provider + Terraform version constraints
├── main.tf               # Root module — wires all child modules
├── variables.tf          # All input variables with validation
├── outputs.tf            # Key outputs (ALB DNS, EC2 IPs, subnet IDs)
├── terraform.tfvars      # Default variable values (edit before applying)
└── modules/
    ├── vpc/              # VPC + Internet Gateway
    ├── subnets/          # Public (×2) + Private (×4) subnets
    ├── routing/          # IGW RT, Public RT, Private RTs (×4)
    ├── security_groups/  # ALB SG + EC2 SG (least-privilege rules)
    ├── alb/              # ALB, Target Group, HTTP listener
    └── ec2/              # Ubuntu NGINX instances + IAM role (SSM)
```

---

## Prerequisites

| Tool        | Minimum version |
|-------------|-----------------|
| Terraform   | 1.6.0           |
| AWS CLI     | 2.x             |
| AWS account | IAM perms for VPC, EC2, ELB, IAM |

---

## Quick Start

```bash
# 1. Clone / download this repository
cd terraform-aws-infra

# 2. Configure AWS credentials
export AWS_PROFILE=my-profile   # or use environment variables

# 3. Edit variable values
vim terraform.tfvars

# 4. Initialise providers and modules
terraform init

# 5. Preview changes
terraform plan

# 6. Apply
terraform apply

# 7. Get the ALB endpoint
terraform output alb_dns_name
```

Open `http://<alb_dns_name>` in a browser — you will see the NGINX
instance health page identifying which instance and AZ served the request.

---

## Key Variables

| Variable               | Default              | Description                              |
|------------------------|----------------------|------------------------------------------|
| `aws_region`           | `us-east-1`          | AWS region                               |
| `project_name`         | `myapp`              | Prefix for all resource names            |
| `environment`          | `dev`                | `dev` / `staging` / `prod`               |
| `vpc_cidr`             | `10.0.0.0/16`        | VPC CIDR block                           |
| `availability_zones`   | `[us-east-1a/1b]`    | Must be exactly 2 AZs                    |
| `public_subnet_cidrs`  | `[10.0.1/2.0/24]`    | 2 public subnet CIDRs                    |
| `private_subnet_cidrs` | `[10.0.11-22.0/24]`  | 4 private subnet CIDRs                   |
| `instance_type`        | `t3.micro`           | NGINX instance size                      |
| `key_name`             | `null`               | EC2 Key Pair (null = no SSH key)         |
| `ssh_allowed_cidrs`    | `["10.0.0.0/8"]`     | CIDR(s) allowed SSH to EC2               |

---

## Security Notes

- EC2 instances are in **private subnets** — no public IPs.
- Only the ALB security group can send traffic to EC2 on port 80.
- **IMDSv2** is enforced on all EC2 instances (`http_tokens = required`).
- All EBS volumes are **encrypted**.
- **SSM Session Manager** is pre-configured (no bastion needed for shell access).
- SSH is restricted to `ssh_allowed_cidrs` — set this to your VPN CIDR.

---

## Production Checklist

- [ ] Enable `enable_deletion_protection = true` on the ALB
- [ ] Add NAT Gateways for private subnet egress (one per AZ)
- [ ] Add an HTTPS listener with an ACM certificate
- [ ] Enable ALB access logs to S3
- [ ] Add an S3 + DynamoDB backend for remote state
- [ ] Set `environment = "prod"` in `terraform.tfvars`
- [ ] Pin AMI ID instead of using `most_recent = true`
