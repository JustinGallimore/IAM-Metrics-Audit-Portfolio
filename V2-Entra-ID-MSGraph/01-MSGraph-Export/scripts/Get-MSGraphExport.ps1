# IAM Lab V2 - MS Graph Export Script
# Purpose: Authenticate to MS Graph and export Entra ID identity data to CSV
# Author: Justin Gallimore
# Date: 2026

$tenantId     = "YOUR_TENANT_ID_HERE"
$clientId     = "YOUR_CLIENT_ID_HERE"
$clientSecret = "YOUR_CLIENT_SECRET_HERE"
$outputPath   = "C:\IAMLab\IAM-Metrics-Audit-Lab-V2\01-MSGraph-Export\output-samples"

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   MS GRAPH EXPORT - $(Get-Date -Format 'MM/dd/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Step 1: Authenticating to MS Graph..." -ForegroundColor Yellow
$tokenUrl  = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$tokenBody = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
}

$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $tokenBody
$accessToken   = $tokenResponse.access_token
Write-Host "Authentication successful." -ForegroundColor Green

$headers = @{ Authorization = "Bearer $accessToken" }

Write-Host "Step 2: Pulling user data from Entra ID..." -ForegroundColor Yellow
$usersUrl      = "https://graph.microsoft.com/v1.0/users?`$select=displayName,userPrincipalName,accountEnabled,department,jobTitle,createdDateTime"
$usersResponse = Invoke-RestMethod -Uri $usersUrl -Headers $headers -Method GET
$users         = $usersResponse.value
Write-Host "Retrieved $($users.Count) users from Entra ID." -ForegroundColor Green

Write-Host "Step 3: Exporting user inventory..." -ForegroundColor Yellow
$userExport = $users | Select-Object `
    displayName,
    userPrincipalName,
    accountEnabled,
    department,
    jobTitle,
    createdDateTime

$userExport | Export-Csv -Path "$outputPath\EntraID_User_Inventory.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "Step 4: Generating KPI summary..." -ForegroundColor Yellow
$totalUsers    = $users.Count
$enabledUsers  = ($users | Where-Object { $_.accountEnabled -eq $true }).Count
$disabledUsers = ($users | Where-Object { $_.accountEnabled -eq $false }).Count
$noDepUsers    = ($users | Where-Object { $_.department -eq $null -or $_.department -eq "" }).Count

$deptBreakdown = $users | Group-Object department |
    Select-Object Name, Count |
    Sort-Object Count -Descending

$kpiSummary = [PSCustomObject]@{
    ReportDate         = Get-Date -Format "MM/dd/yyyy"
    TotalUsers         = $totalUsers
    EnabledUsers       = $enabledUsers
    DisabledUsers      = $disabledUsers
    EnabledPercent     = "$([math]::Round(($enabledUsers/$totalUsers)*100,1))%"
    DisabledPercent    = "$([math]::Round(($disabledUsers/$totalUsers)*100,1))%"
    NoDepartmentUsers  = $noDepUsers
    DataSource         = "Microsoft Entra ID via MS Graph"
    TenantDomain       = "justingallimoregmail.onmicrosoft.com"
}

$kpiSummary | Export-Csv -Path "$outputPath\EntraID_KPI_Summary.csv" -NoTypeInformation
$deptBreakdown | Export-Csv -Path "$outputPath\EntraID_Department_Breakdown.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "Step 5: Exporting disabled accounts report..." -ForegroundColor Yellow
$users | Where-Object { $_.accountEnabled -eq $false } |
    Select-Object displayName, userPrincipalName, department, jobTitle, createdDateTime |
    Export-Csv -Path "$outputPath\EntraID_Disabled_Accounts.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   EXPORT COMPLETE" -ForegroundColor Cyan
Write-Host "   Total Users: $totalUsers" -ForegroundColor Cyan
Write-Host "   Enabled: $enabledUsers | Disabled: $disabledUsers" -ForegroundColor Cyan
Write-Host "   Files saved to: $outputPath" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Get-ChildItem $outputPath | Select-Object Name, LastWriteTime | Format-Table -AutoSize
