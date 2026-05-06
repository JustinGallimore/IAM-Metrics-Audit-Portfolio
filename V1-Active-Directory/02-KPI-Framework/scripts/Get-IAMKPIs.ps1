# IAM Lab - KPI Framework Script
# Purpose: Generate key IAM metrics from Active Directory
# Author: Your Name
# Date: 2026

$outputPath = "C:\IAMLab\IAM-Metrics-Audit-Lab\02-KPI-Framework\output-samples"
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

$allUsers = Get-ADUser -Filter * -Properties `
    DisplayName, SamAccountName, Enabled, `
    LastLogonDate, PasswordLastSet, `
    Department, Title, Created

$totalAccounts      = $allUsers.Count
$enabledAccounts    = ($allUsers | Where-Object { $_.Enabled -eq $true }).Count
$disabledAccounts   = ($allUsers | Where-Object { $_.Enabled -eq $false }).Count
$neverLoggedIn      = ($allUsers | Where-Object { $_.LastLogonDate -eq $null }).Count
$stalePasswords     = ($allUsers | Where-Object {
    $_.PasswordLastSet -ne $null -and
    $_.PasswordLastSet -lt (Get-Date).AddDays(-90)
}).Count
$noPasswordSet      = ($allUsers | Where-Object { $_.PasswordLastSet -eq $null }).Count
$enabledPercent     = [math]::Round(($enabledAccounts / $totalAccounts) * 100, 1)
$disabledPercent    = [math]::Round(($disabledAccounts / $totalAccounts) * 100, 1)

$departmentBreakdown = $allUsers |
    Group-Object Department |
    Select-Object Name, Count |
    Sort-Object Count -Descending

$disabledUsers = $allUsers |
    Where-Object { $_.Enabled -eq $false } |
    Select-Object DisplayName, SamAccountName, Department, Title, LastLogonDate, PasswordLastSet

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   IAM KPI REPORT - $(Get-Date -Format 'MM/dd/yyyy')" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Accounts        : $totalAccounts"
Write-Host "Enabled Accounts      : $enabledAccounts ($enabledPercent%)"
Write-Host "Disabled Accounts     : $disabledAccounts ($disabledPercent%)"
Write-Host "Never Logged In       : $neverLoggedIn"
Write-Host "Stale Passwords 90d+  : $stalePasswords"
Write-Host "No Password Set       : $noPasswordSet"
Write-Host "`nAccounts by Department:" -ForegroundColor Yellow
$departmentBreakdown | Format-Table -AutoSize
Write-Host "========================================`n" -ForegroundColor Cyan

$kpiSummary = [PSCustomObject]@{
    ReportDate          = Get-Date -Format "MM/dd/yyyy"
    TotalAccounts       = $totalAccounts
    EnabledAccounts     = $enabledAccounts
    DisabledAccounts    = $disabledAccounts
    EnabledPercent      = "$enabledPercent%"
    DisabledPercent     = "$disabledPercent%"
    NeverLoggedIn       = $neverLoggedIn
    StalePasswords90Days = $stalePasswords
    NoPasswordSet       = $noPasswordSet
}

$kpiSummary | Export-Csv -Path "$outputPath\KPI_Summary_Report.csv" -NoTypeInformation
$departmentBreakdown | Export-Csv -Path "$outputPath\KPI_Department_Breakdown.csv" -NoTypeInformation
$disabledUsers | Export-Csv -Path "$outputPath\KPI_Disabled_Users.csv" -NoTypeInformation

Write-Host "KPI reports saved to $outputPath" -ForegroundColor Green
