# Deployment Guide

## Prerequisites

1. **AWS Account**: Target customer AWS account
2. **GitHub Repository**: This repository in customer's GitHub organization
3. **AWS CLI**: Configured with admin permissions for bootstrap
4. **GitHub Secrets**: Configure repository secrets

## Step 1: Repository Setup

### 1.1 Clone Repository
```bash
git clone https://github.com/YOUR_ORG/aws-customer-infra.git
cd aws-customer-infra
```

### 1.2 Configure GitHub Secrets
Go to repository **Settings → Secrets and variables → Actions**

Add these secrets:
- `AWS_ACCOUNT_ID`: Your AWS account ID (12 digits)

Add these variables:
- `AWS_REGION`: Your preferred AWS region (e.g., `us-east-1`)

## Step 2: Bootstrap AWS Account

### 2.1 Deploy OIDC Provider
```bash
aws cloudformation deploy \
  --template-file bootstrap/oidc-provider.yml \
  --stack-name github-oidc-provider \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### 2.2 Deploy GitHub Role
```bash
aws cloudformation deploy \
  --template-file bootstrap/github-deploy-role.yml \
  --stack-name github-deploy-role \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    GitHubOrg=YOUR_GITHUB_ORG \
    GitHubRepo=aws-customer-infra \
  --region us-east-1
```

**Replace `YOUR_GITHUB_ORG` with your actual GitHub organization name.**

## Step 3: Deploy Infrastructure

### 3.1 Deploy Network (VPC)
1. Go to **Actions** tab in GitHub
2. Select **Deploy AWS Infrastructure** workflow
3. Click **Run workflow**
4. Configure:
   - **Environment**: `dev`
   - **Deploy Network**: `true`
   - **Deploy EC2**: `false`
   - **VPC CIDR**: `10.0.0.0/16`
   - **AZ Count**: `2`
   - **Public Subnets**: `true`
   - **Private Subnets**: `true`
   - **NAT Type**: `single`

### 3.2 Deploy Compute (EC2)
1. Run workflow again with:
   - **Environment**: `dev`
   - **Deploy Network**: `false`
   - **Deploy EC2**: `true`
   - **OS Type**: `AmazonLinux2023`
   - **Instance Family**: `t3`
   - **Instance Size**: `micro`
   - **Instance Count**: `1`
   - **Subnet Type**: `public`
   - **Associate Public IP**: `true`

## Step 4: Verify Deployment

### 4.1 Check CloudFormation Stacks
```bash
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
```

### 4.2 Verify Resources
```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev"

# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"
```

### 4.3 Test Web Server
1. Get instance public IP from CloudFormation outputs
2. Visit `http://PUBLIC_IP` in browser
3. Should see "Hello from dev Environment" page

## Step 5: Production Deployment

### 5.1 Configure GitHub Environment
1. Go to **Settings → Environments**
2. Create environment named `prod`
3. Add protection rules:
   - Required reviewers
   - Wait timer (optional)

### 5.2 Deploy Production
1. Run workflow with:
   - **Environment**: `prod`
   - **Deploy Network**: `true`
   - **VPC CIDR**: `10.1.0.0/16`
   - **AZ Count**: `3`
   - **NAT Type**: `per-az`

2. Deploy compute:
   - **Environment**: `prod`
   - **Deploy EC2**: `true`
   - **Instance Family**: `m6i`
   - **Instance Size**: `large`
   - **Instance Count**: `3`
   - **Subnet Type**: `private`
   - **Associate Public IP**: `false`

## Troubleshooting

### Common Issues

#### 1. OIDC Trust Relationship
**Error**: `AssumeRoleWithWebIdentity is not authorized`

**Solution**: Verify GitHub organization and repository names in bootstrap role:
```bash
aws iam get-role --role-name GitHubDeployRole --query 'Role.AssumeRolePolicyDocument'
```

#### 2. VPC Export Not Found
**Error**: `Export dev-VpcId cannot be imported`

**Solution**: Deploy network stack first, then compute stack.

#### 3. Insufficient Permissions
**Error**: `User is not authorized to perform: ec2:CreateVpc`

**Solution**: Ensure GitHub role has PowerUserAccess policy attached.

### Validation Commands

```bash
# Check stack status
aws cloudformation describe-stacks --stack-name dev-network

# List exports
aws cloudformation list-exports

# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"

# Test SSM connectivity
aws ssm describe-instance-information
```

## Next Steps

### Add More Services
1. Create new CloudFormation template (e.g., `database/rds.yml`)
2. Import VPC resources using `Fn::ImportValue`
3. Add workflow inputs for service configuration
4. Update GitHub Actions workflow

### Customize Parameters
1. Edit parameter files in `parameters/dev/` and `parameters/prod/`
2. Commit changes to trigger deployments

### Monitor Resources
1. Set up CloudWatch dashboards
2. Configure billing alerts
3. Enable AWS Config for compliance