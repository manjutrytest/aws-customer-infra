# AWS Infrastructure Architecture

## Overview

This repository implements a modular, option-driven AWS infrastructure deployment using CloudFormation templates and GitHub Actions CI/CD.

## Architecture Principles

### 1. Foundation-First Design
- **Network (VPC)** is the foundation layer
- **Compute (EC2)** consumes network resources via CloudFormation exports
- Future services (RDS, ALB, ECS, EKS) will follow the same pattern

### 2. Option-Driven Configuration
- All infrastructure options are selectable via GitHub Actions UI
- No need to edit CloudFormation templates for different configurations
- Parameters drive template behavior through conditions and mappings

### 3. Environment Strategy
- **dev**: Development environment with minimal resources
- **prod**: Production environment with high availability
- Same templates, different parameters
- GitHub Environments provide approval gates

## Network Architecture

### VPC Design
```
VPC (10.0.0.0/16 or 10.1.0.0/16)
├── Public Subnets (optional)
│   ├── AZ-1: 10.x.0.0/24
│   ├── AZ-2: 10.x.1.0/24
│   └── AZ-3: 10.x.2.0/24
├── Private Subnets (optional)
│   ├── AZ-1: 10.x.3.0/24
│   ├── AZ-2: 10.x.4.0/24
│   └── AZ-3: 10.x.5.0/24
├── Internet Gateway (if public subnets)
└── NAT Gateways (configurable)
    ├── None
    ├── Single (cost-effective)
    └── Per-AZ (high availability)
```

### Network Options
- **VPC CIDR**: Configurable IP range
- **Availability Zones**: 1, 2, or 3 AZs
- **Public Subnets**: Enable/disable
- **Private Subnets**: Enable/disable
- **NAT Gateway**: None, single, or per-AZ

## Compute Architecture

### EC2 Design
- **Launch Template**: Standardized instance configuration
- **Security Groups**: Environment-specific access rules
- **IAM Roles**: SSM and CloudWatch permissions
- **User Data**: Automated setup and configuration

### Compute Options
- **Operating System**: Amazon Linux, Ubuntu, RHEL, Windows
- **Instance Family**: t3, t3a, m5, m6i
- **Instance Size**: micro, small, medium, large
- **Instance Count**: 1-5 instances
- **Subnet Placement**: Public or private
- **Public IP**: Enable/disable

## Security Architecture

### OIDC Authentication
```
GitHub Actions → GitHub OIDC Provider → AWS STS → Assume Role
```

### IAM Strategy
- **No static AWS credentials**
- **Repository-specific trust policy**
- **Environment-aware permissions**
- **Least-privilege access**

### Security Groups
- **SSH/RDP access** for management
- **HTTP/HTTPS access** for web services
- **Outbound internet access** for updates

## Deployment Flow

### 1. Bootstrap (One-time)
```bash
# Deploy OIDC provider
aws cloudformation deploy --template-file bootstrap/oidc-provider.yml

# Deploy GitHub role
aws cloudformation deploy --template-file bootstrap/github-deploy-role.yml
```

### 2. Infrastructure Deployment
```
GitHub Actions Workflow
├── Select Environment (dev/prod)
├── Choose Components (network/compute)
├── Configure Options (dropdowns)
├── Deploy Network (if selected)
├── Deploy Compute (if selected)
└── Display Outputs
```

### 3. Dependency Management
- **EC2 depends on VPC** via CloudFormation exports
- **Deployment order enforced** by workflow logic
- **Automatic resource discovery** via export/import values

## Future Extensions

### Planned Services
- **RDS**: Database layer consuming private subnets
- **ALB**: Load balancer in public subnets
- **ECS**: Container orchestration
- **EKS**: Kubernetes clusters

### Extension Pattern
1. Create new CloudFormation template in dedicated folder
2. Import VPC resources via `Fn::ImportValue`
3. Add workflow inputs for service options
4. Update GitHub Actions workflow
5. Add parameter files for environments

## Environment Differences

### Development
- **Single AZ** for cost optimization
- **Single NAT Gateway** or none
- **Smaller instances** (t3.micro)
- **Public subnets** for easy access

### Production
- **Multi-AZ** for high availability
- **NAT Gateway per AZ** for redundancy
- **Larger instances** (m6i.large)
- **Private subnets** for security

## Cost Optimization

### Development
- Use t3.micro instances (free tier eligible)
- Single NAT Gateway or none
- Minimal AZ usage

### Production
- Right-size instances based on workload
- Use Spot instances where appropriate
- Monitor and optimize NAT Gateway usage

## Monitoring and Observability

### CloudWatch Integration
- **Instance metrics** via CloudWatch agent
- **VPC Flow Logs** for network monitoring
- **Custom dashboards** per environment

### SSM Integration
- **Session Manager** for secure access
- **Parameter Store** for configuration
- **Systems Manager** for patch management