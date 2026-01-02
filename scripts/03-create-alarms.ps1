# 03-create-alarms.ps1
# Creates CloudWatch alarms and sends notifications to SNS

$ErrorActionPreference = "Stop"

$TOPIC_ARN = (Get-Content .\scripts\.topic_arn.txt -ErrorAction Stop).Trim()
$ALB_DIM   = (Get-Content .\scripts\.alb_dim.txt  -ErrorAction Stop).Trim()
$TG_DIM    = (Get-Content .\scripts\.tg_dim.txt   -ErrorAction Stop).Trim()

Write-Host "Using TOPIC_ARN:" $TOPIC_ARN
Write-Host "ALB_DIM:" $ALB_DIM
Write-Host "TG_DIM:" $TG_DIM

# Alarm 1: ALB 5XX errors
aws cloudwatch put-metric-alarm `
  --alarm-name "proj5-ALB-5XX-High" `
  --alarm-description "ALB is returning 5XX errors (>=1 in 1 minute)" `
  --namespace "AWS/ApplicationELB" `
  --metric-name "HTTPCode_ELB_5XX_Count" `
  --dimensions Name=LoadBalancer,Value=$ALB_DIM `
  --statistic Sum `
  --period 60 `
  --evaluation-periods 1 `
  --threshold 1 `
  --comparison-operator GreaterThanOrEqualToThreshold `
  --treat-missing-data notBreaching `
  --alarm-actions $TOPIC_ARN | Out-Null

# Alarm 2: Target group unhealthy hosts
aws cloudwatch put-metric-alarm `
  --alarm-name "proj5-TG-Unhealthy-Hosts" `
  --alarm-description "Target group has unhealthy hosts (>0)" `
  --namespace "AWS/ApplicationELB" `
  --metric-name "UnHealthyHostCount" `
  --dimensions Name=TargetGroup,Value=$TG_DIM Name=LoadBalancer,Value=$ALB_DIM `
  --statistic Average `
  --period 60 `
  --evaluation-periods 1 `
  --threshold 0 `
  --comparison-operator GreaterThanThreshold `
  --treat-missing-data notBreaching `
  --alarm-actions $TOPIC_ARN | Out-Null

# Alarm 3: High latency
aws cloudwatch put-metric-alarm `
  --alarm-name "proj5-ALB-High-Latency" `
  --alarm-description "Target response time > 2s for 2 minutes" `
  --namespace "AWS/ApplicationELB" `
  --metric-name "TargetResponseTime" `
  --dimensions Name=LoadBalancer,Value=$ALB_DIM `
  --statistic Average `
  --period 60 `
  --evaluation-periods 2 `
  --threshold 2 `
  --comparison-operator GreaterThanThreshold `
  --treat-missing-data notBreaching `
  --alarm-actions $TOPIC_ARN | Out-Null

Write-Host "✅ Alarms created:"
aws cloudwatch describe-alarms --query "MetricAlarms[?starts_with(AlarmName,'proj5-')].[AlarmName,StateValue]" --output table
