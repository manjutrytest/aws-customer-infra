# Quick script to restore Linux instance alongside Windows
# This deploys a separate stack for Linux instances

Write-Host "🔧 Restoring Linux instance alongside Windows..." -ForegroundColor Green

# Deploy Linux instance as separate stack
aws cloudformation deploy `
  --template-file compute/ec2-simple.yml `
  --stack-name dev-compute-linux `
  --parameter-overrides `
    Environment=dev `
    OperatingSystem=AmazonLinux2023 `
    InstanceFamily=t3 `
    InstanceSize=micro `
    InstanceCount=1 `
    SubnetType=private `
    AssociatePublicIp=false `
    RootVolumeSize=20 `
    RootVolumeType=gp3 `
  --capabilities CAPABILITY_IAM `
  --no-fail-on-empty-changeset `
  --region eu-north-1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Linux instance restored successfully!" -ForegroundColor Green
    Write-Host "📋 You now have both Linux and Windows instances running" -ForegroundColor Cyan
} else {
    Write-Host "❌ Failed to restore Linux instance!" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 Check your instances:" -ForegroundColor Yellow
aws ec2 describe-instances `
  --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" `
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0],State.Name]' `
  --output table `
  --region eu-north-1