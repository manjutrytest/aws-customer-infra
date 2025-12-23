@echo off
echo 🚀 Starting AWS Bootstrap Process...

REM Prerequisites:
REM 1. AWS CLI installed and configured with admin permissions
REM 2. Replace YOUR_GITHUB_ORG and YOUR_REPO_NAME with actual values

echo.
echo 📋 Step 1: Deploying GitHub OIDC Provider...
aws cloudformation deploy ^
  --template-file bootstrap/oidc-provider.yml ^
  --stack-name github-oidc-provider ^
  --capabilities CAPABILITY_IAM ^
  --region us-east-1

if %errorlevel% neq 0 (
    echo ❌ OIDC Provider deployment failed!
    pause
    exit /b 1
)

echo ✅ OIDC Provider deployed successfully!

echo.
echo 📋 Step 2: Deploying GitHub Deployment Role...
echo ⚠️  Please update GitHubOrg and GitHubRepo parameters below!

aws cloudformation deploy ^
  --template-file bootstrap/github-deploy-role.yml ^
  --stack-name github-deploy-role ^
  --capabilities CAPABILITY_IAM ^
  --parameter-overrides ^
    GitHubOrg=YOUR_GITHUB_ORG ^
    GitHubRepo=aws-customer-infra ^
  --region us-east-1

if %errorlevel% neq 0 (
    echo ❌ GitHub Deployment Role deployment failed!
    pause
    exit /b 1
)

echo ✅ GitHub Deployment Role deployed successfully!

echo.
echo 📋 Step 3: Getting deployment outputs...

echo 🔍 OIDC Provider Details:
aws cloudformation describe-stacks ^
  --stack-name github-oidc-provider ^
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" ^
  --output table

echo.
echo 🔍 GitHub Role Details:
aws cloudformation describe-stacks ^
  --stack-name github-deploy-role ^
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" ^
  --output table

echo.
echo 🎉 Bootstrap completed successfully!
echo.
echo 📝 Next Steps:
echo 1. Go to your GitHub repository Settings → Secrets and variables → Actions
echo 2. Add AWS_ACCOUNT_ID as a secret (your 12-digit AWS account ID)
echo 3. Add AWS_REGION as a variable (e.g., us-east-1)
echo 4. Go to Actions tab and run the 'Deploy AWS Infrastructure' workflow

pause