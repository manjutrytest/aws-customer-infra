# Bootstrap Commands for AWS Customer Infrastructure
# Run these commands to set up OIDC and GitHub deployment role

# Prerequisites:
# 1. AWS CLI installed and configured with admin permissions
# 2. Replace YOUR_GITHUB_ORG and YOUR_REPO_NAME with actual values

Write-Host "🚀 Starting AWS Bootstrap Process..." -ForegroundColor Green

# Step 1: Deploy OIDC Provider
Write-Host "📋 Step 1: Deploying GitHub OIDC Provider..." -ForegroundColor Yellow
aws cloudformation deploy `
  --template-file bootstrap/oidc-provider.yml `
  --stack-name github-oidc-provider `
  --capabilities CAPABILITY_IAM `
  --region us-east-1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ OIDC Provider deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ OIDC Provider deployment failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Deploy GitHub Deployment Role
Write-Host "📋 Step 2: Deploying GitHub Deployment Role..." -ForegroundColor Yellow
Write-Host "⚠️  Please update GitHubOrg and GitHubRepo parameters below!" -ForegroundColor Red

aws cloudformation deploy `
  --template-file bootstrap/github-deploy-role.yml `
  --stack-name github-deploy-role `
  --capabilities CAPABILITY_IAM `
  --parameter-overrides `
    GitHubOrg=YOUR_GITHUB_ORG `
    GitHubRepo=aws-customer-infra `
  --region us-east-1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ GitHub Deployment Role deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ GitHub Deployment Role deployment failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Get outputs for GitHub configuration
Write-Host "📋 Step 3: Getting deployment outputs..." -ForegroundColor Yellow

Write-Host "🔍 OIDC Provider Details:" -ForegroundColor Cyan
aws cloudformation describe-stacks `
  --stack-name github-oidc-provider `
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' `
  --output table

Write-Host "🔍 GitHub Role Details:" -ForegroundColor Cyan
aws cloudformation describe-stacks `
  --stack-name github-deploy-role `
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' `
  --output table

Write-Host "🎉 Bootstrap completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Go to your GitHub repository Settings → Secrets and variables → Actions"
Write-Host "2. Add AWS_ACCOUNT_ID as a secret (your 12-digit AWS account ID)"
Write-Host "3. Add AWS_REGION as a variable (e.g., us-east-1)"
Write-Host "4. Go to Actions tab and run the 'Deploy AWS Infrastructure' workflow"