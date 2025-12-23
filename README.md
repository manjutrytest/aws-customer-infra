# AWS Infrastructure Deployment

Option-driven AWS infrastructure deployment using CloudFormation, GitHub Actions, and OIDC authentication.

## 🏗️ Architecture

This repository deploys AWS infrastructure in a modular, option-driven approach:

- **Network Foundation**: VPC with configurable subnets, gateways, and AZs
- **Compute Layer**: EC2 instances that consume the network foundation
- **Future-Ready**: Designed to support RDS, ALB, ECS, EKS without refactoring

## 🚀 Quick Start

### 1. Configure Existing OIDC Roles

Since you already have OIDC provider and roles set up, just configure them for your repository:

**Option A: Use the automated script (Recommended)**
```powershell
# PowerShell (Windows)
.\configure-existing-roles.ps1

# Or Command Prompt (Windows)
configure-existing-roles.bat
```

**Option B: Manual configuration**
Update the trust policy of your existing roles to include your repository:
- **GitHubActionsOIDCRole-dev** (for dev environment)
- **GitHubActionsOIDCRole-prod** (for prod environment)

### 2. Configure GitHub Repository

1. Go to **Settings → Secrets and variables → Actions**
2. Add these secrets:
   - `AWS_ACCOUNT_ID`: `821706771879`
3. Add these variables:
   - `AWS_REGION`: `eu-north-1`

### 3. Deploy Infrastructure

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
- **Count**: 1-3 instances
- **Subnet Type**: Public or private
- **Public IP**: Enable/disable
- **Storage Size**: 8GB to 200GB root volume
- **Storage Type**: gp2, gp3, io1, io2

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