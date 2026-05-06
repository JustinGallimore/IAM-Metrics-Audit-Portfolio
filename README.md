# IAM Metrics and Audit Evidence System

**Built by Justin Gallimore | IAM Engineer**  
[LinkedIn](https://www.linkedin.com/in/justingallimore) | [GitHub](https://github.com/justingallimore)

\---

## What This Project Is

This is a two-version Identity and Access Management portfolio project that demonstrates real enterprise IAM engineering skills. It covers identity inventory, KPI reporting, audit evidence collection, cloud identity integration using Microsoft Entra ID and MS Graph API, and executive-level dashboard reporting using Power BI.

Version 1 was built entirely on-premises using Active Directory and PowerShell. Version 2 took everything from Version 1 and scaled it to the cloud using Microsoft Entra ID, MS Graph API, and Power BI Desktop. Together they tell a hybrid identity story that shows both on-prem and cloud IAM engineering in one portfolio.

This is not a tutorial project. Every script, every report, and every dashboard was built hands-on in a real homelab environment running Windows Server 2022 in VMware Workstation connected to a live Microsoft Entra ID tenant.

\---

## Tools and Technologies Used

**Version 1**

* Windows Server 2022 (VMware Workstation homelab)
* Active Directory Domain Services
* PowerShell 5.1
* HTML and CSS (dark-themed dashboard)

**Version 2**

* Microsoft Entra ID (Azure AD)
* Microsoft Graph API
* PowerShell with MSAL authentication
* Power BI Desktop
* Azure Cloud Shell
* Microsoft 365 Developer Tenant

\---

## Folder Structure

```
IAM-Metrics-Audit-Portfolio/
    README.md
    V1-Active-Directory/
        01-Identity-Inventory/
        02-KPI-Framework/
        03-Audit-Evidence/
        04-Dashboard/
        05-Executive-Summary/
        README.md
    V2-Entra-ID-MSGraph/
        01-MSGraph-Export/
            scripts/
            screenshots/
            exports/
        02-PowerBI-Dashboard/
            screenshots/
            IAM\\\_Dashboard\\\_V2.pbix
```

\---

## Version 1: Active Directory and PowerShell

### What Version 1 Demonstrates

Version 1 shows how to build a functioning IAM audit and reporting system using only tools available in most enterprise on-premises environments. No cloud required. Just Active Directory, PowerShell, and a browser.

The goal was to answer three questions that every IAM team gets asked during audits:

* Who has access right now and what does that look like across the organization?
* Are we meeting our key performance indicators around account hygiene?
* Can we produce timestamped audit evidence on demand?

\---

### Phase 1: Identity Inventory

The first thing any IAM engineer does when they walk into an environment is take inventory. You cannot govern what you cannot see.

**Screenshot 01 - PowerShell Folders Created**

!\[01\_powershell\_folders\_created](V1-Active-Directory/01-Identity-Inventory/screenshots/01\_powershell\_folders\_created.png)

The project folder structure was built using PowerShell. This is the starting point. Five phase folders were created at C:\\IAMLab\\IAM-Metrics-Audit-Lab to keep scripts, reports, and evidence organized the same way a real enterprise IAM team would organize a project drive.

\---

**Screenshot 02 - File Explorer Folder Tree**

!\[02\_file\_explorer\_folder\_tree](V1-Active-Directory/01-Identity-Inventory/screenshots/02\_file\_explorer\_folder\_tree.png)

This confirms the folder structure from inside File Explorer. In a real audit engagement you would want to show an auditor exactly where your evidence lives and that it is organized in a repeatable way. This screenshot serves that purpose.

\---

**Screenshot 03 - Script File Created**

!\[03\_script\_file\_created](V1-Active-Directory/01-Identity-Inventory/screenshots/03\_script\_file\_created.png)

The identity inventory script was written to pull every user account from Active Directory and export it as a timestamped CSV file. The script captures account name, department, enabled or disabled status, last logon date, and password last set date. These are the exact fields that show up in SOC 2 and ISO 27001 access reviews.

\---

**Screenshot 04 - Identity Inventory Complete**

!\[04\_identity\_inventory\_complete](V1-Active-Directory/01-Identity-Inventory/screenshots/04\_identity\_inventory\_complete.png)

The script ran successfully and exported the full user inventory. This is what a completed identity pull looks like in a real environment. Every account in the domain is now visible in a structured report that can be handed to a compliance team or an auditor.

\---

**Screenshot 05 - Identity Inventory CSV in Notepad**

!\[05\_identity\_inventory\_csv\_notepad](V1-Active-Directory/01-Identity-Inventory/screenshots/05\_identity\_inventory\_csv\_notepad.png)

The raw CSV output opened in Notepad confirms the data structure. Each row is one user account. Each column maps to a field that matters for identity governance like department, enabled status, and last logon. This is the data layer that everything else in the project is built on top of.

\---

**Screenshot 06 - Dummy Users Created**

!\[06\_dummy\_users\_created](V1-Active-Directory/01-Identity-Inventory/screenshots/06\_dummy\_users\_created.png)

15 realistic test users were created in Active Directory across Engineering, Finance, HR, IT, and Marketing departments. The accounts include a mix of enabled and disabled status to simulate a real workforce. Having disabled accounts in the environment is intentional because finding and reporting on disabled accounts is one of the core functions of identity governance.

\---

**Screenshot 07 - Identity Inventory Updated**

!\[07\_identity\_inventory\_updated](V1-Active-Directory/01-Identity-Inventory/screenshots/07\_identity\_inventory\_updated.png)

After the dummy users were created the inventory script was run again to capture the updated account list. This demonstrates that the script is repeatable and always reflects the current state of the directory. In a real environment this script would be scheduled to run on a recurring basis.

\---

### Phase 2: KPI Framework

Once you have your identity inventory the next step is calculating KPIs. These are the numbers that leadership and compliance teams actually care about.

**Screenshot 08 - KPI Script Created**

!\[08\_kpi\_script\_created](V1-Active-Directory/02-KPI-Framework/screenshots/08\_kpi\_script\_created.png)

The KPI framework script was built to calculate six core IAM metrics from the Active Directory data. Total accounts, enabled versus disabled ratio, accounts that have never logged in, accounts with stale passwords, and user distribution by department. These six metrics cover the most common questions that come up in access reviews and security audits.

\---

**Screenshot 09 - KPI Report Output**

!\[09\_kpi\_report\_output](V1-Active-Directory/02-KPI-Framework/screenshots/09\_kpi\_report\_output.png)

The script ran and produced the KPI output in the terminal. This confirms that the calculations are working and the data is being pulled correctly from Active Directory. In a real environment this output would feed into a ticketing system or a reporting dashboard.

\---

**Screenshot 10 - KPI CSV Files Confirmed**

!\[10\_kpi\_csv\_files\_confirmed](V1-Active-Directory/02-KPI-Framework/screenshots/10\_kpi\_csv\_files\_confirmed.png)

Three structured CSV files were exported from the KPI script. One for the overall KPI summary, one for department breakdown, and one for accounts flagged as non-compliant. These files are the evidence artifacts that you would attach to an audit finding or a leadership report.

\---

### Phase 3: Audit Evidence Collection

This phase is about producing the kind of timestamped documentation that satisfies SOC 2 Type II and ISO 27001 control requirements.

**Screenshot 11 - Audit Evidence Script Created**

!\[11\_audit\_evidence\_script\_created](V1-Active-Directory/03-Audit-Evidence/screenshots/11\_audit\_evidence\_script\_created.png)

The audit evidence collection script was written to generate five date-stamped evidence files automatically. In a real audit you cannot just say you reviewed access. You have to show documented proof with timestamps. This script automates that documentation process.

\---

**Screenshot 12 - Audit Evidence Collection Complete**

!\[12\_audit\_evidence\_collection\_complete](V1-Active-Directory/03-Audit-Evidence/screenshots/12\_audit\_evidence\_collection\_complete.png)

All five evidence files were generated and saved successfully. Each file is timestamped and maps to a specific compliance control. This is what audit-ready evidence looks like when it comes from an automated IAM process instead of someone manually pulling screenshots at 11pm the night before an audit.

\---

### Phase 4: Dashboard

The dashboard takes all of the data collected in the previous phases and puts it into a format that non-technical stakeholders can actually read and understand.

**Screenshot 13 - Dashboard Created**

!\[13\_dashboard\_created](V1-Active-Directory/04-Dashboard/screenshots/13\_dashboard\_created.png)

A dark-themed HTML dashboard was built using PowerShell to generate the HTML from the KPI data. It includes severity-rated findings and compliance control status indicators. The entire dashboard opens in any browser with no additional software required.

\---

**Screenshot 14 - Dashboard Browser View**

!\[14\_dashboard\_browser\_view](V1-Active-Directory/04-Dashboard/screenshots/14\_dashboard\_browser\_view.png)

This is the finished dashboard rendered in a browser. A hiring manager, a CISO, or an auditor could open this file and immediately understand the state of identity in the environment. That is the point of an IAM dashboard. It takes raw Active Directory data and turns it into something a business can act on.

\---

### Phase 5: Executive Summary

**Screenshot 15 - Executive Summary Created**

!\[15\_executive\_summary\_created](V1-Active-Directory/05-Executive-Summary/15\_executive\_summary\_created.png)

A professional executive summary was written and saved as a markdown file. This document translates the technical findings into business language. It covers what was built, what was found, what controls are in place, and what the compliance posture looks like.

\---

**Screenshot 16 - README Created**

!\[16\_readme\_created](V1-Active-Directory/05-Executive-Summary/16\_readme\_created.png)

The Version 1 README was created with LinkedIn and GitHub links embedded. This is the documentation layer that makes the project navigable for anyone who lands on the repo.

\---

**Screenshot 17 - Final File Confirmation**

!\[17\_final\_file\_confirmation](V1-Active-Directory/05-Executive-Summary/17\_final\_file\_confirmation.png)

Final confirmation that all files across all five phases are in place. Version 1 is complete. The honest rating for Version 1 is a 6.5 out of 10. The governance concepts are solid and the PowerShell work is real, but the tooling is on-premises only. Version 2 fixes that.

\---

## Version 2: Microsoft Entra ID and MS Graph API

### What Version 2 Demonstrates

Version 2 takes the same IAM governance framework from Version 1 and rebuilds it in the cloud using Microsoft Entra ID, MS Graph API, and Power BI. This is the tooling that actual enterprise IAM teams are using right now at mid to large organizations.

The pipeline works like this. An app registration in Entra ID authenticates to MS Graph API using a client secret. A PowerShell script uses that authentication to pull user data from the cloud directory and export it as CSV files. Those CSV files are imported into Power BI Desktop where the dashboard is built. This is not a workaround. This is how real enterprise IAM reporting pipelines are built.

\---

### Setting Up the Cloud Environment

**Screenshot 01 - Entra Admin Center**

!\[01\_entra\_admin\_center](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/01\_entra\_admin\_center.png)

This is the Microsoft Entra admin center. Think of this as the control panel for cloud identity. Every user account, every app, every access policy in a Microsoft cloud environment is managed from here. The tenant created for this project is a real Azure tenant with the domain justingallimoregmail.onmicrosoft.com.

\---

**Screenshot 02 - Entra Tenant Overview**

!\[02\_entra\_tenant\_overview](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/02\_entra\_tenant\_overview.png)

The tenant overview confirms the environment is live and active. The Tenant ID is c9075a8a-c6d6-4c44-a3f3-019324df1ec1. In enterprise IAM this tenant ID is how you identify which cloud directory you are working in, especially in multi-tenant environments.

\---

### Registering the Application

To pull data from Microsoft's cloud directory programmatically you need to register an application and give it permission. This is the same process IAM engineers follow when onboarding any tool that needs to talk to Entra ID.

**Screenshot 03 - App Registrations Empty**

!\[03\_app\_registrations\_empty](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/03\_app\_registrations\_empty.png)

This is the App Registrations page before anything was created. Starting from a clean state is important for a portfolio project because it shows the entire process from scratch rather than picking up partway through.

\---

**Screenshot 04 - App Registration Complete**

!\[04\_app\_registration\_complete](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/04\_app\_registration\_complete.png)

The application called IAM-Metrics-Dashboard was registered successfully with Application ID e65bd0c4-4fb7-4202-9313-0d0bc22fe192. This application is what authenticates to MS Graph on behalf of the reporting pipeline. In a real enterprise this app registration would be documented, its permissions reviewed quarterly, and its secrets rotated on a defined schedule.

\---

### Configuring API Permissions

**Screenshot 05 - API Permissions Default**

!\[05\_api\_permissions\_default](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/05\_api\_permissions\_default.png)

This shows the default permissions state after app registration. By default an app has almost no access. You have to explicitly grant each permission it needs. This is the principle of least privilege in action at the application level.

\---

**Screenshot 06 - API Permissions Configured**

!\[06\_api\_permissions\_configured](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/06\_api\_permissions\_configured.png)

Six MS Graph API permissions were added to the application. User.Read.All pulls all user accounts. Group.Read.All pulls group memberships. Directory.Read.All reads the full directory structure. AuditLog.Read.All accesses sign-in and audit logs. IdentityRiskyUser.Read.All pulls risky user detections. User.Read allows the app to read its own profile. Each of these maps directly to a real IAM reporting use case.

\---

**Screenshot 07 - Admin Consent Granted**

!\[07\_admin\_consent\_granted](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/07\_admin\_consent\_granted.png)

Admin consent was granted for all permissions. This step is critical. Without admin consent the application cannot use any of the permissions even if they are listed. In enterprise environments only a Global Administrator or Privileged Role Administrator can grant this consent which is why it requires an approval workflow in most organizations.

\---

**Screenshot 08 - Client Secret Created**

!\[08\_client\_secret\_created](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/08\_client\_secret\_created.png)

A client secret called IAM-Dashboard-Secret was created with an expiration of May 2028. The client secret is how the PowerShell script proves to MS Graph that it is the registered application. An important real-world lesson from this project is that the Secret Value and the Secret ID are two different things. The script needs the Secret Value. Using the Secret ID by mistake causes a 401 authentication failure which is exactly what happened during the build of this project and was debugged and fixed.

\---

### Running the PowerShell Export

**Screenshot 09 - Cloud Shell Open**

!\[09\_cloud\_shell\_open](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/09\_cloud\_shell\_open.png)

Azure Cloud Shell was used to connect to Microsoft Graph PowerShell and create the cloud users for the tenant. Cloud Shell is a browser-based terminal that runs inside Azure with no local installation required. It is already authenticated to your Azure subscription which makes it useful for quick administrative tasks.

\---

**Screenshot 10 - Graph Connected**

!\[10\_graph\_connected](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/10\_graph\_connected.png)

The PowerShell session connected to Microsoft Graph successfully. This confirms that the authentication chain is working. App registration, permissions, and admin consent all have to be correct for this connection to succeed.

\---

**Screenshot 11 - Entra Users Created**

!\[11\_entra\_users\_created](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/11\_entra\_users\_created.png)

10 realistic cloud users were created in the Entra ID tenant across Engineering, Finance, HR, and IT departments. Combined with the admin account the tenant now has 11 total users. The mix includes enabled and disabled accounts to simulate a real workforce the same way the Active Directory environment did in Version 1.

\---

**Screenshot 12 - Entra Users Confirmed**

!\[12\_entra\_users\_confirmed](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/12\_entra\_users\_confirmed.png)

All 11 users confirmed in the Entra admin center. This view shows exactly what an IAM engineer would see when doing a manual access review in a real Entra ID environment.

\---

**Screenshot 13 - V2 Folder Structure Created**

!\[13\_v2\_folder\_structure\_created](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/13\_v2\_folder\_structure\_created.png)

The Version 2 folder structure was created on the Windows Server 2022 VM at C:\\IAMLab\\IAM-Metrics-Audit-Lab-V2. Keeping a clean and documented folder structure is not just about organization. It is evidence that the work was done in a methodical and repeatable way which is something auditors and interviewers both pay attention to.

\---

**Screenshot 14 - MSGraph Script Created**

!\[14\_msgraph\_script\_created](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/14\_msgraph\_script\_created.png)

The Get-MSGraphExport.ps1 script was written to authenticate to Entra ID using the app credentials and pull all user data through MS Graph. The script uses client credential flow which is the correct authentication method for background processes that run without a user signing in interactively. This is how automated IAM reporting tools authenticate in production environments.

\---

**Screenshot 15 - MSGraph Export Success**

!\[15\_msgraph\_export\_success](V2-Entra-ID-MSGraph/01-MSGraph-Export/screenshots/15\_msgraph\_export\_success.png)

The script ran successfully and exported four CSV files. EntraID\_User\_Inventory.csv contains the full user list. EntraID\_KPI\_Summary.csv contains the calculated metrics. EntraID\_Department\_Breakdown.csv contains the user count by department. EntraID\_Disabled\_Accounts.csv contains the list of disabled accounts. Two real errors were encountered and fixed during this build. The first was using the Secret ID instead of the Secret Value. The second was a 403 Forbidden error on the signInActivity field because that field requires a premium Entra ID license. Both were debugged and resolved cleanly.

\---

### Building the Power BI Dashboard

**Screenshot 16 - Power BI Data Preview**

!\[16\_powerbi\_data\_preview](V2-Entra-ID-MSGraph/02-PowerBI-Dashboard/Screenshots/)

Power BI Desktop was opened and all four CSV files were imported as tables. This is the data preview step where you confirm that the data loaded correctly before building any visuals. The decision to use a PowerShell to CSV to Power BI pipeline instead of trying to connect Power BI directly to MS Graph is worth explaining here. Direct MS Graph connections in Power BI Desktop have limitations around personal Microsoft accounts and custom authorization headers. The CSV pipeline is actually how real enterprise IAM teams operate because it gives you a clean audit trail of exactly what data was pulled and when.

\---

**Screenshot 17 - Power BI All Tables Loaded**

!\[17\_powerbi\_all\_tables\_loaded](V2-Entra-ID-MSGraph/02-PowerBI-Dashboard/Screenshots/17\_powerbi\_all\_tables\_loaded.png)

All four tables are loaded and visible in the Power BI data model. Having the data split across four purpose-built tables instead of one flat export mirrors how enterprise reporting data is structured. Each table has a specific job and answers a specific question which makes the dashboard easier to maintain and extend over time.

\---

**Screenshot 18 - Power BI Dashboard Complete**

!\[18\_powerbi\_dashboard\_complete](V2-Entra-ID-MSGraph/02-PowerBI-Dashboard/Screenshots/18\_powerbi\_dashboard\_complete.png)

The completed IAM Dashboard shows five KPI cards across the top. Total users at 11, enabled users at 8, disabled users at 3, enabled percent at 72.73%, and disabled percent at 27.27%. Below that is a clustered bar chart showing user count by department across Finance, HR, Engineering, and IT. A table shows the three disabled accounts which are Lisa Turner in HR, Robert Chen in Finance, and Sarah Johnson in Finance. A donut chart on the right visualizes the enabled versus disabled ratio. The dashboard was saved as IAM\_Dashboard\_V2.pbix.

\---

## What This Project Proves

This project demonstrates the full IAM engineering lifecycle from identity discovery to compliance reporting using both on-premises and cloud tools.

On the technical side it shows hands-on experience with Active Directory, PowerShell automation, Microsoft Entra ID, MS Graph API authentication using client credential flow, Power BI data modeling and dashboard design, and audit evidence generation aligned to SOC 2 and ISO 27001.

On the governance side it shows the ability to ask the right questions about an identity environment, calculate meaningful KPIs, produce audit-ready evidence, and communicate findings at both a technical and executive level.

The honest combined rating is a 9 out of 10. The gap is closed by connecting to a live Entra ID environment with real API calls and real data visualization. The only thing that would push this to a 10 is Entra Connect syncing the on-prem Active Directory to the Entra tenant to demonstrate true hybrid identity which is the natural next phase of this project.

\---

## Contact

**Justin Gallimore**  
IAM Engineer  
[LinkedIn](https://www.linkedin.com/in/justingallimore) | [GitHub](https://github.com/justingallimore)

