# Configure Existing OIDC Roles for Repository Access
# This script updates the trust policy of existing GitHubActionsDevRole and GitHubActionsProdRole
# to include your repository: manjutrytest/aws-customer-infra

Write-Host "🔧 Configuring existing OIDC roles for repository access..." -ForegroundColor Green

# Repository details
$GitHubOrg = "manjutrytest"
$GitHubRepo = "aws-customer-infra"
$AWSRegion = "eu-north-1"
$AWSAccountId = "821706771879"

Write-Host "📋 Repository: $GitHubOrg/$GitHubRepo" -ForegroundColor Cyan
Write-Host "📋 AWS Region: $AWSRegion" -ForegroundColor Cyan
Write-Host "📋 AWS Account: $AWSAccountId" -ForegroundColor Cyan

# Trust policy template for both roles
$TrustPolicy = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$AWSAccountId:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:$GitHubOrg/$GitHubRepo:*"
        }
      }
    }
  ]
}
"@

# Save trust policy to temporary file
$TrustPolicyFile = "trust-policy.json"
$TrustPolicy | Out-File -FilePath $TrustPolicyFile -Encoding UTF8

Write-Host "📝 Trust policy created: $TrustPolicyFile" -ForegroundColor Yellow

# Update GitHubActionsDevRole
Write-Host "🔄 Updating GitHubActionsDevRole trust policy..." -ForegroundColor Yellow
try {
    aws iam update-assume-role-policy `
        --role-name GitHubActionsDevRole `
        --policy-document file://$TrustPolicyFile `
        --region $AWSRegion
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHubActionsDevRole updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to update GitHubActionsDevRole!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error updating GitHubActionsDevRole: $_" -ForegroundColor Red
}

# Update GitHubActionsProdRole
Write-Host "🔄 Updating GitHubActionsProdRole trust policy..." -ForegroundColor Yellow
try {
    aws iam update-assume-role-policy `
        --role-name GitHubActionsProdRole `
        --policy-document file://$TrustPolicyFile `
        --region $AWSRegion
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHubActionsProdRole updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to update GitHubActionsProdRole!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error updating GitHubActionsProdRole: $_" -ForegroundColor Red
}

# Cleanup
Remove-Item $TrustPolicyFile -ErrorAction SilentlyContinue

# Verify the roles
Write-Host "🔍 Verifying role configurations..." -ForegroundColor Cyan

Write-Host "📋 GitHubActionsDevRole trust policy:" -ForegroundColor Yellow
aws iam get-role --role-name GitHubActionsDevRole --query 'Role.AssumeRolePolicyDocument' --region $AWSRegion

Write-Host "📋 GitHubActionsProdRole trust policy:" -ForegroundColor Yellow
aws iam get-role --role-name GitHubActionsProdRole --query 'Role.AssumeRolePolicyDocument' --region $AWSRegion

Write-Host ""
Write-Host "🎉 Configuration completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Go to your GitHub repository: https://github.com/$GitHubOrg/$GitHubRepo"
Write-Host "2. Navigate to Settings → Secrets and variables → Actions"
Write-Host "3. Add these secrets and variables:"
Write-Host "   Secrets:"
Write-Host "   - AWS_ACCOUNT_ID: $AWSAccountId"
Write-Host "   Variables:"
Write-Host "   - AWS_REGION: $AWSRegion"
Write-Host "4. Go to Actions tab and run the 'Deploy AWS Infrastructure' workflow"
Write-Host "5. Select 'dev' environment first to test the setup"