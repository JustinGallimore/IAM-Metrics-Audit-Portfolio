# IAM Lab - Audit Evidence Collection Script
# Purpose: Generate audit ready evidence package from Active Directory
# Author: Your Name
# Date: 2026

$auditDate = Get-Date -Format "yyyy-MM-dd"
$auditTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$outputPath = "C:\IAMLab\IAM-Metrics-Audit-Lab\03-Audit-Evidence\evidence-samples"
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   AUDIT EVIDENCE COLLECTION" -ForegroundColor Cyan
Write-Host "   $auditTime" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allUsers = Get-ADUser -Filter * -Properties `
    DisplayName, SamAccountName, Enabled, `
    LastLogonDate, PasswordLastSet, `
    Department, Title, Manager, `
    Created, DistinguishedName, `
    MemberOf

Write-Host "Collecting Evidence 1 of 5: User Access Report..." -ForegroundColor Yellow
$allUsers | Select-Object `
    DisplayName, SamAccountName, Enabled, `
    LastLogonDate, PasswordLastSet, `
    Department, Title, Created |
Export-Csv -Path "$outputPath\Evidence_01_User_Access_Report_$auditDate.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "Collecting Evidence 2 of 5: Disabled Accounts Report..." -ForegroundColor Yellow
$allUsers | Where-Object { $_.Enabled -eq $false } |
Select-Object `
    DisplayName, SamAccountName, `
    Department, Title, `
    LastLogonDate, PasswordLastSet, Created |
Export-Csv -Path "$outputPath\Evidence_02_Disabled_Accounts_$auditDate.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "Collecting Evidence 3 of 5: Privileged Accounts Report..." -ForegroundColor Yellow
$domainAdmins = Get-ADGroupMember -Identity "Domain Admins" -Recursive |
    Where-Object { $_.objectClass -eq "user" } |
    ForEach-Object { Get-ADUser $_ -Properties DisplayName, Department, Title, Enabled, LastLogonDate }

$domainAdmins | Select-Object `
    DisplayName, SamAccountName, `
    Department, Title, Enabled, LastLogonDate |
Export-Csv -Path "$outputPath\Evidence_03_Privileged_Accounts_$auditDate.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "Collecting Evidence 4 of 5: Password Compliance Report..." -ForegroundColor Yellow
$allUsers | Select-Object `
    DisplayName, SamAccountName, `
    Department, Enabled, PasswordLastSet,
    @{Name="PasswordAgeDays"; Expression={
        if ($_.PasswordLastSet) {
            [math]::Round((New-TimeSpan -Start $_.PasswordLastSet -End (Get-Date)).TotalDays)
        } else { "Never Set" }
    }},
    @{Name="CompliantUnder90Days"; Expression={
        if ($_.PasswordLastSet) {
            (New-TimeSpan -Start $_.PasswordLastSet -End (Get-Date)).TotalDays -lt 90
        } else { $false }
    }} |
Export-Csv -Path "$outputPath\Evidence_04_Password_Compliance_$auditDate.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "Collecting Evidence 5 of 5: Audit Metadata Log..." -ForegroundColor Yellow
$metadata = [PSCustomObject]@{
    AuditDate            = $auditDate
    AuditTimestamp       = $auditTime
    CollectedBy          = $env:USERNAME
    ServerName           = $env:COMPUTERNAME
    Domain               = (Get-ADDomain).DNSRoot
    TotalUsersAudited    = $allUsers.Count
    EvidenceFilesCreated = 5
    AuditStandard        = "SOC 2 Type II / ISO 27001"
    ReviewCycle          = "Monthly"
    NextReviewDue        = (Get-Date).AddMonths(1).ToString("yyyy-MM-dd")
}

$metadata | Export-Csv -Path "$outputPath\Evidence_05_Audit_Metadata_$auditDate.csv" -NoTypeInformation
Write-Host "Complete." -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   AUDIT EVIDENCE COLLECTION COMPLETE" -ForegroundColor Cyan
Write-Host "   5 evidence files saved to:" -ForegroundColor Cyan
Write-Host "   $outputPath" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Get-ChildItem $outputPath | Select-Object Name, LastWriteTime, Length | Format-Table -AutoSize
