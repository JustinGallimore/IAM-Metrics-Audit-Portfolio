# Lessons Learned

## IAM-Metrics-Audit-Portfolio

This document covers what broke during the build, what caused it, how it was fixed, and what the production equivalent would look like. These are not hypothetical scenarios. Every issue here happened during real development work and was treated as a production-grade incident.

---

## Issue 01: Hardcoded Client Secret Blocked by GitHub Push Protection

**What broke:**

During V2 development a PowerShell script was written with the Entra ID client secret hardcoded directly in the script body. When the commit was pushed to GitHub the push was blocked by GitHub's Push Protection feature which detected the secret in the code and rejected the push entirely.

**Root cause:**

The client secret was written inline in the script during initial development rather than being passed in as a parameter or pulled from a secure store. This is a credential hygiene failure — secrets should never exist in source code regardless of whether the repo is public or private. GitHub Push Protection caught it before it reached the remote repo but the secret was already in the local commit history.

**How it was fixed:**

This was treated as a real security incident with a full remediation sequence:

1. The commit was amended using `git commit --amend` to rewrite the commit and remove the secret from the code
2. A force push was used to overwrite the remote history: `git push --force`
3. The Entra ID client secret was immediately rotated in the Azure portal — a new secret was generated and the old one was invalidated
4. The script was updated to use a parameter input pattern so credentials are never stored in the script body

**What production looks like:**

In production client secrets and API credentials are stored in Azure Key Vault and retrieved at runtime via managed identity or a service principal with scoped read access. Scripts never contain credentials. Environment variables or secure parameter passing are the minimum acceptable pattern for any script that runs against a live tenant. GitHub Push Protection is a last line of defense — the first line is never writing the secret into the code in the first place.

---

## Issue 02: Screenshot Images Not Rendering on GitHub

**What broke:**

Screenshots embedded in the README using relative paths were not rendering on GitHub. The image placeholders appeared broken despite the files existing in the Screenshots folder locally.

**Root cause:**

Two separate issues caused image rendering failures. The first was path casing — GitHub's file system is case sensitive and a path mismatch between the folder name in the README link and the actual folder name on disk caused the images to 404 silently. The second was a double-extension issue where some files had been saved as `filename.png.png` which caused the file reference in the README to not match the actual filename.

**How it was fixed:**

All image paths in the README were updated to use full raw GitHub URLs in the format:

```
https://raw.githubusercontent.com/JustinGallimore/IAM-Metrics-Audit-Portfolio/main/Screenshots/filename.png
```

Double-extension filenames were corrected by renaming the affected files. All paths were verified by navigating to each raw URL directly in the browser before committing.

**What production looks like:**

In production documentation all image references use absolute paths or are stored in a documentation platform that handles image hosting natively. Relative paths in markdown documentation are fragile across different rendering environments. For any GitHub-hosted documentation raw GitHub URLs are the most reliable format for embedded images.

---

## Issue 03: Power BI Dashboard Showing Blank After Data Source Change

**What broke:**

After migrating from V1 AD data to V2 Entra ID data the Power BI dashboard visuals went blank. The data model loaded without errors but none of the charts or cards rendered data.

**Root cause:**

The V1 data model was built against the CSV column schema from the Active Directory export. When the V2 data source was connected the column names from the MS Graph API export did not match the column names the existing data model was referencing. Power BI could not resolve the field references and rendered blank visuals rather than throwing explicit errors.

**How it was fixed:**

The data model was rebuilt from scratch against the V2 Graph API CSV schema rather than attempting to remap the V1 model. All measures, calculated columns, and visual field references were rebuilt against the new column names. Starting clean was faster and produced a cleaner model than trying to patch the V1 references.

**What production looks like:**

In production any data model change that alters the underlying schema is treated as a breaking change requiring a formal impact assessment on all downstream reports and dashboards before deployment. Column naming conventions are standardized in the data pipeline layer so that schema changes upstream do not cascade into broken visuals. The rebuild approach used here is acceptable in a lab — in production it would be a last resort after a migration impact review.

---

## What I Would Do Differently in Production

Credential handling would follow a secrets manager pattern from the first line of code. No script would ever be written with inline credentials even during initial development. The habit of writing clean credential handling from the start is faster than remediating a push protection block after the fact.

Screenshot and documentation file naming conventions would be established before the first file is saved. Consistent naming, no double extensions, and full raw URLs for all image references would be part of the documentation standard from day one.

The Power BI data model schema would be documented alongside the pipeline so that any future data source change has a clear reference point for what fields exist and what visuals depend on them.

---

*Built by Justin Gallimore | [github.com/JustinGallimore](https://github.com/JustinGallimore)*
