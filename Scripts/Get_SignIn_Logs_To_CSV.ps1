# =============================================================================
# Get_SignIn_Logs_To_CSV.ps1
# Author: Justin Gallimore
# Description: Authenticates to Microsoft Graph API using an Entra ID app
#              registration and pulls sign-in logs for a configurable number
#              of days. Exports the results to a timestamped CSV file for
#              use in Power BI dashboards, access reviews, or audit evidence.
#              This is the data collection script behind the V2 IAM Metrics
#              dashboard — it feeds the sign-in analytics and MFA compliance
#              reporting in the Power BI model.
# =============================================================================

# -----------------------------------------------------------------------------
# CONFIGURATION
# Replace these placeholder values with your actual Entra ID app registration
# details. In production these would be stored in Azure Key Vault or passed
# as environment variables — never hardcoded in the script.
# -----------------------------------------------------------------------------
$TenantID     = "YOUR_TENANT_ID"        # Entra ID tenant ID
$ClientID     = "YOUR_CLIENT_ID"        # App registration client ID
$ClientSecret = "YOUR_CLIENT_SECRET"    # App registration client secret
$DaysBack     = 30                      # How many days of sign-in logs to pull
$OutputPath   = ".\SignIn_Logs_Export_$(Get-Date -Format 'yyyy-MM-dd').csv"   # Output file name with datestamp

# -----------------------------------------------------------------------------
# STEP 1: AUTHENTICATE — GET AN ACCESS TOKEN
# We use OAuth2 client credentials flow to get a token scoped to Microsoft
# Graph. The app registration needs AuditLog.Read.All and Directory.Read.All
# permissions in Entra ID for this to work.
# -----------------------------------------------------------------------------
Write-Host "[*] Requesting access token from Microsoft Identity Platform..." -ForegroundColor Cyan

$TokenURL = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

$TokenBody = @{
    grant_type    = "client_credentials"
    client_id     = $ClientID
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
}

try {
    $TokenResponse = Invoke-RestMethod -Uri $TokenURL -Method POST -Body $TokenBody -ContentType "application/x-www-form-urlencoded"
    $AccessToken = $TokenResponse.access_token
    Write-Host "[+] Access token retrieved successfully." -ForegroundColor Green
}
catch {
    Write-Host "[-] Failed to retrieve access token." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

$Headers = @{
    Authorization  = "Bearer $AccessToken"
    "Content-Type" = "application/json"
}

# -----------------------------------------------------------------------------
# STEP 2: BUILD THE DATE FILTER
# Sign-in logs in Graph API use ISO 8601 datetime format for filtering.
# We calculate the start date based on the DaysBack variable so the script
# is reusable without manual date editing every time it runs.
# -----------------------------------------------------------------------------
$StartDate = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-ddTHH:mm:ssZ")
Write-Host "[*] Pulling sign-in logs from the last $DaysBack days (since $StartDate)..." -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# STEP 3: QUERY SIGN-IN LOGS FROM GRAPH API
# The signInLogs endpoint returns up to 1000 records per page. We handle
# pagination using the @odata.nextLink property so we capture all records
# regardless of how many pages the results span.
# Required Graph permissions: AuditLog.Read.All
# -----------------------------------------------------------------------------
$SignInURL = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge $StartDate&`$top=999&`$select=createdDateTime,userDisplayName,userPrincipalName,appDisplayName,ipAddress,location,status,conditionalAccessStatus,authenticationRequirement,riskLevelDuringSignIn,clientAppUsed,deviceDetail"

$AllSignIns = @()   # Initialize empty array to collect all pages of results

do {
    try {
        $Response = Invoke-RestMethod -Uri $SignInURL -Method GET -Headers $Headers
        $AllSignIns += $Response.value
        $SignInURL = $Response.'@odata.nextLink'   # If there is a next page this will be populated
        Write-Host "[*] Retrieved $($AllSignIns.Count) records so far..." -ForegroundColor Cyan
    }
    catch {
        Write-Host "[-] Failed to retrieve sign-in logs." -ForegroundColor Red
        Write-Host $_.Exception.Message
        exit 1
    }
} while ($SignInURL)   # Keep looping until there are no more pages

Write-Host "[+] Total sign-in records retrieved: $($AllSignIns.Count)" -ForegroundColor Green

# -----------------------------------------------------------------------------
# STEP 4: FLATTEN AND FORMAT THE DATA FOR CSV EXPORT
# Graph API returns nested objects for some fields like status, location, and
# deviceDetail. We flatten these into individual columns so the CSV is clean
# and usable directly in Power BI without additional transformation.
# -----------------------------------------------------------------------------
Write-Host "[*] Formatting data for CSV export..." -ForegroundColor Cyan

$FormattedSignIns = $AllSignIns | ForEach-Object {
    [PSCustomObject]@{
        DateTime                = $_.createdDateTime
        UserDisplayName         = $_.userDisplayName
        UserPrincipalName       = $_.userPrincipalName
        AppDisplayName          = $_.appDisplayName
        IPAddress               = $_.ipAddress
        City                    = $_.location.city
        State                   = $_.location.state
        CountryOrRegion         = $_.location.countryOrRegion
        SignInResult            = if ($_.status.errorCode -eq 0) { "Success" } else { "Failure" }
        FailureReason           = $_.status.failureReason
        ConditionalAccessStatus = $_.conditionalAccessStatus
        AuthRequirement         = $_.authenticationRequirement   # "multiFactorAuthentication" or "singleFactorAuthentication"
        RiskLevel               = $_.riskLevelDuringSignIn
        ClientAppUsed           = $_.clientAppUsed
        DeviceOS                = $_.deviceDetail.operatingSystem
        Browser                 = $_.deviceDetail.browser
        IsCompliant             = $_.deviceDetail.isCompliant
    }
}

# -----------------------------------------------------------------------------
# STEP 5: EXPORT TO CSV
# Write the flattened data to a timestamped CSV file in the current directory.
# This file feeds directly into the Power BI dashboard for visualization.
# -----------------------------------------------------------------------------
try {
    $FormattedSignIns | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "[+] Sign-in logs exported successfully." -ForegroundColor Green
    Write-Host "[+] Output file: $OutputPath"
    Write-Host "[+] Total records exported: $($FormattedSignIns.Count)"
}
catch {
    Write-Host "[-] Failed to export CSV." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# -----------------------------------------------------------------------------
# STEP 6: SUMMARY STATS
# Print a quick summary of what the data looks like so you can sanity check
# the export before loading it into Power BI.
# -----------------------------------------------------------------------------
$SuccessCount  = ($FormattedSignIns | Where-Object { $_.SignInResult -eq "Success" }).Count
$FailureCount  = ($FormattedSignIns | Where-Object { $_.SignInResult -eq "Failure" }).Count
$MFACount      = ($FormattedSignIns | Where-Object { $_.AuthRequirement -eq "multiFactorAuthentication" }).Count
$LegacyCount   = ($FormattedSignIns | Where-Object { $_.ClientAppUsed -notmatch "Browser|Mobile Apps|Modern Auth" }).Count

Write-Host ""
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host " Sign-In Log Export Summary" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host " Date Range     : Last $DaysBack days"
Write-Host " Total Records  : $($FormattedSignIns.Count)"
Write-Host " Successful     : $SuccessCount"
Write-Host " Failed         : $FailureCount"
Write-Host " MFA Required   : $MFACount"
Write-Host " Legacy Auth    : $LegacyCount"
Write-Host " Output File    : $OutputPath"
Write-Host " Timestamp      : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "=============================================" -ForegroundColor Yellow
