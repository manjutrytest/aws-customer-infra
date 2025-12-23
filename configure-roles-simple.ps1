# Simple script to configure existing OIDC roles for repository access
# Repository: manjutrytest/aws-customer-infra

Write-Host "🔧 Configuring existing OIDC roles..." -ForegroundColor Green

# Create trust policy JSON file
$trustPolicyContent = @'
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
'@

# Write trust policy to file
$trustPolicyContent | Out-File -FilePath "trust-policy.json" -Encoding UTF8
Write-Host "📝 Trust policy created: trust-policy.json" -ForegroundColor Yellow

# Update GitHubActionsOIDCRole-dev
Write-Host "🔄 Updating GitHubActionsOIDCRole-dev..." -ForegroundColor Yellow
aws iam update-assume-role-policy --role-name GitHubActionsOIDCRole-dev --policy-document file://trust-policy.json --region eu-north-1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ GitHubActionsOIDCRole-dev updated successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to update GitHubActionsOIDCRole-dev!" -ForegroundColor Red
}

# Update GitHubActionsOIDCRole-prod
Write-Host "🔄 Updating GitHubActionsOIDCRole-prod..." -ForegroundColor Yellow
aws iam update-assume-role-policy --role-name GitHubActionsOIDCRole-prod --policy-document file://trust-policy.json --region eu-north-1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ GitHubActionsOIDCRole-prod updated successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to update GitHubActionsOIDCRole-prod!" -ForegroundColor Red
}

# Cleanup
Remove-Item "trust-policy.json" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎉 Configuration completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Go to GitHub repository: https://github.com/manjutrytest/aws-customer-infra"
Write-Host "2. Settings → Secrets and variables → Actions"
Write-Host "3. Add AWS_ACCOUNT_ID secret: 821706771879"
Write-Host "4. Add AWS_REGION variable: eu-north-1"
Write-Host "5. Go to Actions tab and run Deploy AWS Infrastructure workflow"