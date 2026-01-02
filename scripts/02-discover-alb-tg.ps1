# 02-discover-alb-tg.ps1
# This Discovers an ALB and one target group and also saves ARNs + dimension strings.

$ErrorActionPreference = "Stop"

# List ALBs in region
$lbs = aws elbv2 describe-load-balancers --query "LoadBalancers[].{Name:LoadBalancerName,Arn:LoadBalancerArn,DNS:DNSName,Type:Type}" --output json | ConvertFrom-Json
if (-not $lbs) { throw "No load balancers found in this region." }

Write-Host "Load balancers found:"
$lbs | Format-Table Name,Type,DNS -AutoSize


$alb = $lbs | Where-Object { $_.Type -eq "application" -and $_.Name -like "tf-*" } | Select-Object -First 1
if (-not $alb) { $alb = $lbs | Where-Object { $_.Type -eq "application" } | Select-Object -First 1 }

if (-not $alb) { throw "No application load balancer found." }

$ALB_ARN = $alb.Arn
$ALB_DNS = $alb.DNS

Write-Host ""
Write-Host "✅ Selected ALB:" $alb.Name
Write-Host "ALB_DNS:" $ALB_DNS
Write-Host "ALB_ARN:" $ALB_ARN

# this gets the target groups for the ALB
$tgs = aws elbv2 describe-target-groups --load-balancer-arn $ALB_ARN --query "TargetGroups[].{Name:TargetGroupName,Arn:TargetGroupArn,Port:Port,Proto:Protocol}" --output json | ConvertFrom-Json
if (-not $tgs) { throw "No target groups found for selected ALB." }

Write-Host ""
Write-Host "Target groups for ALB:"
$tgs | Format-Table Name,Proto,Port -AutoSize

# This picks the first TG
$tg = $tgs | Select-Object -First 1
$TG_ARN = $tg.Arn

# CloudWatch dimension strings 
$ALB_DIM = ($ALB_ARN -split "loadbalancer/")[1]
$TG_DIM  = ($TG_ARN  -split "targetgroup/")[1]

# And thern we save for later scripts
$ALB_ARN | Out-File -Encoding ascii .\scripts\.alb_arn.txt
$TG_ARN  | Out-File -Encoding ascii .\scripts\.tg_arn.txt
$ALB_DIM | Out-File -Encoding ascii .\scripts\.alb_dim.txt
$TG_DIM  | Out-File -Encoding ascii .\scripts\.tg_dim.txt
$ALB_DNS | Out-File -Encoding ascii .\scripts\.alb_dns.txt

Write-Host ""
Write-Host "Saved:"
Write-Host " - scripts\.alb_arn.txt"
Write-Host " - scripts\.tg_arn.txt"
Write-Host " - scripts\.alb_dim.txt"
Write-Host " - scripts\.tg_dim.txt"
Write-Host " - scripts\.alb_dns.txt"
