# 04-lambda-versioning.ps1
$ErrorActionPreference = "Stop"

Write-Host "Region:" $env:AWS_REGION
aws lambda list-functions --query "Functions[].FunctionName" --output table

$FN = Read-Host "Paste the Lambda FunctionName to protect"

$VER = aws lambda publish-version --function-name $FN --query "Version" --output text
Write-Host "✅ Published version:" $VER

try {
  aws lambda create-alias --function-name $FN --name prod --function-version $VER --description "Production alias" | Out-Null
  Write-Host "✅ Alias 'prod' created -> version $VER"
} catch {
  aws lambda update-alias --function-name $FN --name prod --function-version $VER | Out-Null
  Write-Host "✅ Alias 'prod' updated -> version $VER"
}

aws lambda get-alias --function-name $FN --name prod --output table

Write-Host ""
Write-Host "ROLLBACK COMMAND (copy/paste later if needed):"
Write-Host "aws lambda update-alias --function-name $FN --name prod --function-version <PREVIOUS_VERSION>"
