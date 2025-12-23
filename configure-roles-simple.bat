@echo off
echo 🔧 Configuring existing OIDC roles...

REM Create trust policy JSON file
echo Creating trust policy file...
(
echo {
echo   "Version": "2012-10-17",
echo   "Statement": [
echo     {
echo       "Effect": "Allow",
echo       "Principal": {
echo         "Federated": "arn:aws:iam::821706771879:oidc-provider/token.actions.githubusercontent.com"
echo       },
echo       "Action": "sts:AssumeRoleWithWebIdentity",
echo       "Condition": {
echo         "StringEquals": {
echo           "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
echo         },
echo         "StringLike": {
echo           "token.actions.githubusercontent.com:sub": "repo:manjutrytest/aws-customer-infra:*"
echo         }
echo       }
echo     }
echo   ]
echo }
) > trust-policy.json

echo 📝 Trust policy created: trust-policy.json

REM Update GitHubActionsOIDCRole-dev
echo 🔄 Updating GitHubActionsOIDCRole-dev...
aws iam update-assume-role-policy --role-name GitHubActionsOIDCRole-dev --policy-document file://trust-policy.json --region eu-north-1

if %errorlevel% equ 0 (
    echo ✅ GitHubActionsOIDCRole-dev updated successfully!
) else (
    echo ❌ Failed to update GitHubActionsOIDCRole-dev!
)

REM Update GitHubActionsOIDCRole-prod
echo 🔄 Updating GitHubActionsOIDCRole-prod...
aws iam update-assume-role-policy --role-name GitHubActionsOIDCRole-prod --policy-document file://trust-policy.json --region eu-north-1

if %errorlevel% equ 0 (
    echo ✅ GitHubActionsOIDCRole-prod updated successfully!
) else (
    echo ❌ Failed to update GitHubActionsOIDCRole-prod!
)

REM Cleanup
del trust-policy.json 2>nul

echo.
echo 🎉 Configuration completed!
echo.
echo 📝 Next Steps:
echo 1. Go to GitHub repository: https://github.com/manjutrytest/aws-customer-infra
echo 2. Settings → Secrets and variables → Actions
echo 3. Add AWS_ACCOUNT_ID secret: 821706771879
echo 4. Add AWS_REGION variable: eu-north-1
echo 5. Go to Actions tab and run Deploy AWS Infrastructure workflow

pause