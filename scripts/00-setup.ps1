# 00-setup.ps1
# Sets region and confirms AWS CLI identity

$ErrorActionPreference = "Stop"

# Change if needed
if (-not $env:AWS_REGION) { $env:AWS_REGION = "us-east-1" }

Write-Host "Region:" $env:AWS_REGION

aws sts get-caller-identity --output table
