# Deployment Guide

## Prerequisites

1. **AWS Account**: Your AWS account (821706771879) with existing OIDC setup
2. **GitHub Repository**: https://github.com/manjutrytest/aws-customer-infra
3. **Existing OIDC Infrastructure**: 
   - Stack: `oidc-infra-shared` in `eu-north-1`
   - Roles: `GitHubActionsOIDCRole-dev` and `GitHubActionsOIDCRole-prod`
4. **AWS CLI**: Configured with permissions to update IAM roles

## Step 1: Repository Setup

### 1.1 Clone Repository
```bash
git clone https://github.com/YOUR_ORG/aws-customer-infra.git
cd aws-customer-infra
```

### 1.2 Configure GitHub Secrets
Go to repository **Settings → Secrets and variables → Actions**

Add these secrets:
- `AWS_ACCOUNT_ID`: `821706771879`

Add these variables:
- `AWS_REGION`: `eu-north-1`

## Step 2: Configure Existing OIDC Roles

Since you already have OIDC provider and roles, we just need to update their trust policies to include your repository.

### 2.1 Quick Configuration (Recommended)
Run the automated configuration script:

**PowerShell:**
```powershell
.\configure-existing-roles.ps1
```

**Command Prompt:**
```cmd
configure-existing-roles.bat
```

### 2.2 Manual Configuration (Alternative)

**Create trust policy file (trust-policy.json):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::821706771879:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:manjutrytest/aws-customer-infra:*"
        }
      }
    }
  ]
}
```

**Update the roles:**
```powershell
# Update dev role
aws iam update-assume-role-policy `
    --role-name GitHubActionsOIDCRole-dev `
    --policy-document file://trust-policy.json `
    --region eu-north-1

# Update prod role
aws iam update-assume-role-policy `
    --role-name GitHubActionsOIDCRole-prod `
    --policy-document file://trust-policy.json `
    --region eu-north-1
```

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
```powershell
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --region eu-north-1
```

### 4.2 Verify Resources
```powershell
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev" --region eu-north-1

# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev" --region eu-north-1
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

**Solution**: Verify repository trust policy in existing roles:
```powershell
aws iam get-role --role-name GitHubActionsOIDCRole-dev --query 'Role.AssumeRolePolicyDocument' --region eu-north-1
aws iam get-role --role-name GitHubActionsOIDCRole-prod --query 'Role.AssumeRolePolicyDocument' --region eu-north-1
```

#### 2. VPC Export Not Found
**Error**: `Export dev-VpcId cannot be imported`

**Solution**: Deploy network stack first, then compute stack.

#### 3. Insufficient Permissions
**Error**: `User is not authorized to perform: ec2:CreateVpc`

**Solution**: Ensure your existing roles have the necessary permissions. Check attached policies:
```powershell
aws iam list-attached-role-policies --role-name GitHubActionsOIDCRole-dev --region eu-north-1
aws iam list-attached-role-policies --role-name GitHubActionsOIDCRole-prod --region eu-north-1
```

### Validation Commands

```powershell
# Check stack status
aws cloudformation describe-stacks --stack-name dev-network --region eu-north-1

# List exports
aws cloudformation list-exports --region eu-north-1

# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev" --region eu-north-1

# Test SSM connectivity
aws ssm describe-instance-information --region eu-north-1
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