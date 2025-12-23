# AWS Infrastructure Deployment

Option-driven AWS infrastructure deployment using CloudFormation, GitHub Actions, and OIDC authentication.

## 🏗️ Architecture

This repository deploys AWS infrastructure in a modular, option-driven approach:

- **Network Foundation**: VPC with configurable subnets, gateways, and AZs
- **Compute Layer**: EC2 instances that consume the network foundation
- **Future-Ready**: Designed to support RDS, ALB, ECS, EKS without refactoring

## 🚀 Quick Start

### 1. Bootstrap (One-time setup)

Deploy OIDC provider and GitHub deployment role in your target AWS account:

```bash
# Deploy OIDC provider
aws cloudformation deploy \
  --template-file bootstrap/oidc-provider.yml \
  --stack-name github-oidc-provider \
  --capabilities CAPABILITY_IAM

# Deploy GitHub deployment role
aws cloudformation deploy \
  --template-file bootstrap/github-deploy-role.yml \
  --stack-name github-deploy-role \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    GitHubOrg=YOUR_GITHUB_ORG \
    GitHubRepo=YOUR_REPO_NAME
```

### 2. Deploy Infrastructure

1. Go to **Actions** tab in GitHub
2. Select **Deploy AWS Infrastructure** workflow
3. Click **Run workflow**
4. Select your options from dropdowns
5. Deploy network first, then compute

## 📋 Deployment Options

### Network Options
- **VPC CIDR**: Choose your IP range
- **Availability Zones**: 1, 2, or 3 AZs
- **Public Subnets**: Enable/disable
- **Private Subnets**: Enable/disable
- **NAT Gateway**: None, single, or per-AZ

### Compute Options
- **OS**: Amazon Linux 2/2023, Ubuntu 22.04, RHEL 9, Windows 2022
- **Instance Family**: t3, t3a, m5, m6i
- **Instance Size**: micro, small, medium, large
- **Count**: 1-5 instances
- **Subnet Type**: Public or private
- **Public IP**: Enable/disable

## 🔒 Security

- No AWS access keys required
- OIDC-based authentication
- Environment-specific permissions
- Least-privilege IAM roles

## 📁 Repository Structure

```
aws-customer-infra/
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── bootstrap/                      # One-time OIDC setup
├── network/vpc.yml                 # VPC CloudFormation
├── compute/ec2.yml                 # EC2 CloudFormation
├── parameters/                     # Environment parameters
└── docs/architecture.md            # Architecture documentation
```

## 🌍 Environments

- **dev**: Development environment
- **prod**: Production environment (requires approval)

Deploy dev first, then promote to prod using the same templates with different parameters.