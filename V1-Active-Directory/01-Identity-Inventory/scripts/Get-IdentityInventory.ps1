# IAM Lab - Identity Inventory Script
# Purpose: Pull all AD user accounts and export to CSV for audit review
# Author: Your Name
# Date: 2025

# Create output folder if it does not exist
$outputPath = "C:\IAMLab\IAM-Metrics-Audit-Lab\01-Identity-Inventory\output-samples"
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

# Pull all AD users and their key attributes
Get-ADUser -Filter * -Properties `
    DisplayName, `
    SamAccountName, `
    Enabled, `
    LastLogonDate, `
    PasswordLastSet, `
    Department, `
    Title, `
    Manager, `
    Created, `
    DistinguishedName |
Select-Object `
    DisplayName, `
    SamAccountName, `
    Enabled, `
    LastLogonDate, `
    PasswordLastSet, `
    Department, `
    Title, `
    Manager, `
    Created, `
    DistinguishedName |
Export-Csv -Path "$outputPath\IdentityInventory_Sample.csv" -NoTypeInformation

Write-Host "Identity inventory complete. File saved to $outputPath" -ForegroundColor Green
