# IAM Metrics and Audit Evidence System
## Built by: Justin | IAM Engineer Portfolio Project

---

## What This Project Is

This project demonstrates the design and implementation of a real world
Identity and Access Management metrics and audit evidence system built
entirely on Windows Server 2022 and Active Directory.

The goal was to simulate what an IAM engineer does in an enterprise
environment when tasked with proving that identity governance controls
are operating effectively. Every script, report, and dashboard in this
project was built from scratch using PowerShell and produces real output
from a live Active Directory environment.

---

## The Problem This Solves

In enterprise IAM, it is not enough to manage access. You have to prove
you are managing it correctly. Auditors, compliance teams, and leadership
all ask the same questions:

- Who has access to what?
- Are there accounts that should not exist?
- When was access last reviewed?
- Can you produce evidence of that review right now?

Most organizations struggle to answer those questions quickly and
consistently. This project builds the system that makes that possible.

---

## What I Built

### Phase 1: Identity Inventory
Automated PowerShell script that pulls every user account from Active
Directory including account status, last logon date, password age,
department, title, and organizational unit. Output is a timestamped
CSV that serves as a point in time access snapshot.

### Phase 2: KPI Framework
Metrics reporting script that calculates five core IAM KPIs across
the entire directory including enabled versus disabled account ratio,
never logged in accounts, stale password count, and department
distribution. Outputs three structured CSV reports for leadership
and audit review.

### Phase 3: Audit Evidence Collection
Automated evidence collection script that generates a complete audit
package containing five evidence files named and timestamped to meet
SOC 2 Type II and ISO 27001 audit expectations. Evidence includes
user access report, disabled accounts report, privileged accounts
inventory, password compliance report, and audit metadata log.

### Phase 4: IAM Metrics Dashboard
A fully functional HTML dashboard that visualizes all KPI data in a
clean dark themed interface including severity rated findings, 
compliance control status indicators, and department breakdowns.
Requires no paid tools or licenses to run.

### Phase 5: Executive Summary
This document. Written to communicate the purpose, scope, and business
value of the project to both technical and non technical audiences.

---

## Technical Environment

| Component        | Details                        |
|------------------|-------------------------------|
| Operating System | Windows Server 2022            |
| Directory        | Active Directory Domain Services|
| Domain           | lab.local                      |
| Automation       | PowerShell 5.1                 |
| Reporting        | CSV, HTML                      |
| Platform         | VMware Workstation             |
| Users Managed    | 19 accounts across 5 departments|

---

## KPI Results from This Environment

| Metric                  | Value  | Status  |
|-------------------------|--------|---------|
| Total Accounts          | 19     | Tracked |
| Enabled Accounts        | 11     | 57.9%   |
| Disabled Accounts       | 8      | Review  |
| Never Logged In         | 18     | Review  |
| Stale Passwords 90d+    | 0      | Pass    |
| Privileged Accounts     | 1      | Pass    |

---

## Audit Findings Identified

**HIGH: 8 disabled accounts require ownership review**
In a production environment these would be escalated to department
managers to confirm whether each account belongs to a terminated
employee, an inactive service account, or a user on leave.

**HIGH: Test user account enabled with no department assignment**
The testuser account is active but has no department or title
assigned. This would be flagged as an orphaned account risk and
remediated by either assigning ownership or disabling the account.

**MEDIUM: 18 accounts have never logged in**
All lab accounts were created during this build session and have
no login history. In production this metric would trigger a review
of any account inactive for more than 30 days post creation.

---

## Skills This Project Demonstrates

- Identity lifecycle management and access governance
- PowerShell automation for IAM operations
- Audit evidence collection and organization
- KPI tracking and IAM metrics reporting
- Compliance alignment with SOC 2 and ISO 27001 frameworks
- Executive level reporting and documentation
- Active Directory administration and querying

---

## How to Run This Project

1. Clone the repository to a Windows Server environment
2. Ensure Active Directory Domain Services is installed and running
3. Run scripts in order starting with 01-Identity-Inventory
4. Each script saves output to its corresponding output-samples folder
5. Open 04-Dashboard/IAM_Dashboard.html in any browser to view metrics

---

## Author

Justin | IAM Engineer
Specializing in Identity and Access Management, Active Directory,
Microsoft Entra ID, Okta, SailPoint, and CyberArk.

---

*This project was built in a homelab environment to demonstrate
real world IAM engineering skills for portfolio and interview purposes.*
