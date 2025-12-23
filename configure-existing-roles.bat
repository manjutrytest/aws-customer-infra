@echo off
echo 🔧 Configuring existing OIDC roles for repository access...

REM Repository details
set GitHubOrg=manjutrytest
set GitHubRepo=aws-customer-infra
set AWSRegion=eu-north-1
set AWSAccountId=821706771879

echo 📋 Repository: %GitHubOrg%/%GitHubRepo%
echo 📋 AWS Region: %AWSRegion%
echo 📋 AWS Account: %AWSAccountId%

REM Create trust policy JSON
echo Creating trust policy...
(
echo {
echo   "Version": "2012-10-17",
echo   "Statement": [
echo     {
echo       "Effect": "Allow",
echo       "Principal": {
echo         "Federated": "arn:aws:iam::%AWSAccountId%:oidc-provider/token.actions.githubusercontent.com"
echo       },
echo       "Action": "sts:AssumeRoleWithWebIdentity",
echo       "Condition": {
echo         "StringEquals": {
echo           "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
echo         },
echo         "StringLike": {
echo           "token.actions.githubusercontent.com:sub": "repo:%GitHubOrg%/%GitHubRepo%:*"
echo         }
echo       }
echo     }
echo   ]
echo }
) > trust-policy.json

echo 📝 Trust policy created: trust-policy.json

REM Update GitHubActionsDevRole
echo 🔄 Updating GitHubActionsDevRole trust policy...
aws iam update-assume-role-policy ^
    --role-name GitHubActionsDevRole ^
    --policy-document file://trust-policy.json ^
    --region %AWSRegion%

if %errorlevel% equ 0 (
    echo ✅ GitHubActionsDevRole updated successfully!
) else (
    echo ❌ Failed to update GitHubActionsDevRole!
)

REM Update GitHubActionsProdRole
echo 🔄 Updating GitHubActionsProdRole trust policy...
aws iam update-assume-role-policy ^
    --role-name GitHubActionsProdRole ^
    --policy-document file://trust-policy.json ^
    --region %AWSRegion%

if %errorlevel% equ 0 (
    echo ✅ GitHubActionsProdRole updated successfully!
) else (
    echo ❌ Failed to update GitHubActionsProdRole!
)

REM Cleanup
del trust-policy.json 2>nul

REM Verify the roles
echo 🔍 Verifying role configurations...

echo 📋 GitHubActionsDevRole trust policy:
aws iam get-role --role-name GitHubActionsDevRole --query "Role.AssumeRolePolicyDocument" --region %AWSRegion%

echo 📋 GitHubActionsProdRole trust policy:
aws iam get-role --role-name GitHubActionsProdRole --query "Role.AssumeRolePolicyDocument" --region %AWSRegion%

echo.
echo 🎉 Configuration completed!
echo.
echo 📝 Next Steps:
echo 1. Go to your GitHub repository: https://github.com/%GitHubOrg%/%GitHubRepo%
echo 2. Navigate to Settings → Secrets and variables → Actions
echo 3. Add these secrets and variables:
echo    Secrets:
echo    - AWS_ACCOUNT_ID: %AWSAccountId%
echo    Variables:
echo    - AWS_REGION: %AWSRegion%
echo 4. Go to Actions tab and run the 'Deploy AWS Infrastructure' workflow
echo 5. Select 'dev' environment first to test the setup

pause