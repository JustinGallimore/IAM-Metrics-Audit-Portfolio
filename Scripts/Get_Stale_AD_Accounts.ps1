# =============================================================================
# Get_Stale_AD_Accounts.ps1
# Author: Justin Gallimore
# Description: Queries Active Directory for stale user accounts — accounts that
#              have not logged in within a configurable number of days, or that
#              are disabled but still exist in AD. Exports results to CSV for
#              access review, audit evidence, or remediation tracking.
#              This is the V1 audit script in the IAM Metrics Portfolio — it
#              represents the on-premises baseline before the environment was
#              migrated to Entra ID reporting in V2.
#              Stale accounts are one of the most common audit findings in any
#              IAM program. An account that nobody is using but is still enabled
#              is an open door for attackers — this script finds them.
# Prerequisites: Must be run on a domain-joined machine with the Active
#                Directory PowerShell module installed (RSAT or on the DC itself).
# =============================================================================

# -----------------------------------------------------------------------------
# CONFIGURATION
# Adjust these values to match your AD environment and audit requirements.
# -----------------------------------------------------------------------------
$DaysInactive   = 90        # Accounts with no login in this many days are flagged as stale
$SearchBase     = "DC=lab,DC=local"   # LDAP search base — adjust to match your domain
$OutputPath     = ".\Stale_AD_Accounts_$(Get-Date -Format 'yyyy-MM-dd').csv"   # Timestamped output file
$IncludeDisabled = $true    # Set to $false if you only want enabled but inactive accounts

# -----------------------------------------------------------------------------
# STEP 1: IMPORT THE ACTIVE DIRECTORY MODULE
# The AD module ships with RSAT on Windows 10/11 or is available natively on
# Windows Server with the AD DS role installed. Without this module the
# Get-ADUser cmdlets will not be available.
# -----------------------------------------------------------------------------
Write-Host "[*] Importing Active Directory module..." -ForegroundColor Cyan

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "[+] Active Directory module loaded." -ForegroundColor Green
}
catch {
    Write-Host "[-] Failed to import Active Directory module." -ForegroundColor Red
    Write-Host "    Make sure RSAT is installed or run this script on a domain controller."
    Write-Host $_.Exception.Message
    exit 1
}

# -----------------------------------------------------------------------------
# STEP 2: CALCULATE THE STALE DATE THRESHOLD
# We subtract DaysInactive from today to get the cutoff date. Any account
# whose LastLogonDate is older than this date — or null — is considered stale.
# LastLogonDate is a replicated attribute in AD (unlike LastLogon which is
# per-DC and not replicated). Always use LastLogonDate for auditing.
# -----------------------------------------------------------------------------
$StaleDate = (Get-Date).AddDays(-$DaysInactive)
Write-Host "[*] Stale threshold: accounts with no login since $($StaleDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# STEP 3: QUERY STALE ENABLED ACCOUNTS
# We pull all enabled accounts where LastLogonDate is older than the threshold
# OR where LastLogonDate is null — meaning the account has never logged in.
# Never-logged-in accounts are often orphaned service accounts, test accounts,
# or onboarding failures and should always be reviewed.
# -----------------------------------------------------------------------------
Write-Host "[*] Querying Active Directory for stale accounts..." -ForegroundColor Cyan

$StaleAccounts = Get-ADUser -Filter {
    Enabled -eq $true -and (LastLogonDate -lt $StaleDate -or LastLogonDate -notlike "*")
} -SearchBase $SearchBase -Properties `
    DisplayName,
    SamAccountName,
    UserPrincipalName,
    EmailAddress,
    Department,
    Title,
    Manager,
    LastLogonDate,
    PasswordLastSet,
    PasswordNeverExpires,
    Enabled,
    Created,
    DistinguishedName |
Select-Object `
    DisplayName,
    SamAccountName,
    UserPrincipalName,
    EmailAddress,
    Department,
    Title,
    @{Name="Manager"; Expression={ (Get-ADUser $_.Manager -ErrorAction SilentlyContinue).Name }},
    LastLogonDate,
    PasswordLastSet,
    PasswordNeverExpires,
    Enabled,
    Created,
    DistinguishedName,
    @{Name="DaysSinceLastLogin"; Expression={
        if ($_.LastLogonDate) {
            (New-TimeSpan -Start $_.LastLogonDate -End (Get-Date)).Days
        } else {
            "Never logged in"
        }
    }},
    @{Name="AccountStatus"; Expression={ "Stale - Enabled" }}

Write-Host "[+] Found $($StaleAccounts.Count) stale enabled accounts." -ForegroundColor Green

# -----------------------------------------------------------------------------
# STEP 4: QUERY DISABLED ACCOUNTS (OPTIONAL)
# Disabled accounts that still exist in AD after a leaver departure are a
# common finding — they should be moved to a disabled OU and eventually
# deleted after a retention period. This block captures them separately.
# -----------------------------------------------------------------------------
$DisabledAccounts = @()

if ($IncludeDisabled) {
    Write-Host "[*] Querying disabled accounts..." -ForegroundColor Cyan

    $DisabledAccounts = Get-ADUser -Filter {
        Enabled -eq $false
    } -SearchBase $SearchBase -Properties `
        DisplayName,
        SamAccountName,
        UserPrincipalName,
        EmailAddress,
        Department,
        Title,
        LastLogonDate,
        PasswordLastSet,
        Enabled,
        Created,
        DistinguishedName |
    Select-Object `
        DisplayName,
        SamAccountName,
        UserPrincipalName,
        EmailAddress,
        Department,
        Title,
        LastLogonDate,
        PasswordLastSet,
        PasswordNeverExpires,
        Enabled,
        Created,
        DistinguishedName,
        @{Name="DaysSinceLastLogin"; Expression={
            if ($_.LastLogonDate) {
                (New-TimeSpan -Start $_.LastLogonDate -End (Get-Date)).Days
            } else {
                "Never logged in"
            }
        }},
        @{Name="AccountStatus"; Expression={ "Disabled - Pending Review" }}

    Write-Host "[+] Found $($DisabledAccounts.Count) disabled accounts." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# STEP 5: COMBINE AND EXPORT TO CSV
# Merge both result sets into a single CSV so reviewers get a complete picture
# of the AD account hygiene in one file. Each record includes an AccountStatus
# column so the type of finding is clear without filtering.
# -----------------------------------------------------------------------------
$AllResults = @()
$AllResults += $StaleAccounts
$AllResults += $DisabledAccounts

try {
    $AllResults | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "[+] Export completed successfully." -ForegroundColor Green
    Write-Host "[+] Output file: $OutputPath"
}
catch {
    Write-Host "[-] Failed to export CSV." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# -----------------------------------------------------------------------------
# STEP 6: SUMMARY
# Print a quick summary so reviewers know what they are looking at before
# opening the CSV. In a real IAM program this output would feed into a
# remediation ticket or access review workflow.
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host " Stale Account Audit Summary" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host " Domain         : $SearchBase"
Write-Host " Stale Threshold: $DaysInactive days"
Write-Host " Stale Enabled  : $($StaleAccounts.Count)"
Write-Host " Disabled       : $($DisabledAccounts.Count)"
Write-Host " Total Findings : $($AllResults.Count)"
Write-Host " Output File    : $OutputPath"
Write-Host " Timestamp      : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "[!] Review the exported CSV and remediate findings based on your" -ForegroundColor Yellow
Write-Host "    organization's account lifecycle and retention policies." -ForegroundColor Yellow
