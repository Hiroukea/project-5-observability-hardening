# 01-sns-alerts.ps1
# Creates SNS topic and subscribes email for alerts

if (-not $env:AWS_REGION) { $env:AWS_REGION="us-east-2" }
Write-Host "Region:" $env:AWS_REGION

$ErrorActionPreference = "Stop"

$TOPIC_NAME = "proj5-alerts"
$EMAIL      = "ankherdene714@gmail.com"   # change if you want

$TOPIC_ARN = aws sns create-topic --name $TOPIC_NAME --query "TopicArn" --output text
Write-Host "TOPIC_ARN:" $TOPIC_ARN

aws sns subscribe --topic-arn $TOPIC_ARN --protocol email --notification-endpoint $EMAIL | Out-Null

Write-Host ""
Write-Host "✅ Subscription created. IMPORTANT: open your email and click CONFIRM subscription."
Write-Host "Topic:" $TOPIC_NAME
Write-Host "Email:" $EMAIL

# Save topic arn for later scripts
$TOPIC_ARN.Trim() | Out-File -Encoding ascii .\scripts\.topic_arn.txt

