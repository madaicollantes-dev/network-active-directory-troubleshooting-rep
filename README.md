# network-active-directory-troubleshooting-rep
scripts, CLI commands used in my daily basis at work for network diagnostics, Basic Troubleshooting and  Active Directory management via PowerShell.
# Network Diagnostics & Active Directory Automation Toolkit

This repository it is a collection of scripts, automated tools, and documented CLI commands used during my daily operations for enterprise network troubleshooting (including BTS monitoring) and Active Directory administration.

## Tech Stack & Tools
**Scripting & Automation:** PowerShell, Python (Colorama CLI reports).
**Identity & Access Management:** Windows Server Active Directory (AD DS), Azure AD / Entra ID.
**Networking & Telecom:** TCP/IP stack diagnostics via CMD, BTS remote transport validation.

---

## 1. Telecom & Network Diagnostics (CMD / Terminal)
This section focuses on scripts and command sequences used to isolate transport layer faults, verify latency, and check the availability of Base Transceiver Stations (BTS).

### Advanced Network Troubleshooting when facing network issues:
Used heavily during local loop and gateway isolation to diagnose connection drops between the local terminal and node managers:

* **`ipconfig /all`**: Used to verify the complete TCP/IP configuration, ensuring the correct Primary DNS Suffices, DHCP Server visibility, and verifying the specific MAC Address (Physical Address) of the network interface.
* **`ipconfig /release` & `/renew`**: Applied to force the network card to drop its current lease and request a fresh IP allocation from the DHCP server when experiencing APIPA issues (getting the classic `169.254.x.x` subnet).
* **`ipconfig /flushdns`**: Critical when BTS management server IPs or domain mappings change, clearing the local OS resolver cache to prevent connection attempts to obsolete destinations.

* **`ping -t` & `pathping`:** Used to detect intermittent packet loss and isolate exactly which routing hop is dropping traffic toward the cell site.
* **`netstat -ano`:** Employed to verify active ports and process IDs running critical management protocols (SSH, SFTP, HTTP) on local gateway elements.
* **`tracert` & `nslookup`:** Used for troubleshooting DNS resolution and validating core network paths to the Mobile Management Entity (MME)

## 2. Active Directory Infrastructure Management (PowerShell)
Automation scripts designed to handle daily User Account Management (IAM), access provisioning, and infrastructure audit tasks efficiently, reducing Tier 1/2 response times.

### Audit and  Localization scipts:
* **`Unlock-ADUser-Bulk.ps1`:** A quick terminal tool to scan and unlock corporate domain accounts securely.
* **`Get-StaleAccountsReport.ps1`:** Automatically fetches domain users who haven't logged in over the last 90 days and exports a clean CSV report for security compliance.
**`New-BulkUsersFromCSV.ps1`:** Reads an onboarding HR spreadsheet, maps corporate attributes, puts users in their respective Organizational Units (OUs), and assigns initial security groups.

**To find a  Service Accounts (`Managed Service Accounts / Service Principals`):**
  Utilizing `Get-ADServiceAccount` or filtering standard accounts via `Get-ADUser -Filter 'ServicePrincipalNames -like "*"'` to audit non-human accounts running critical system background processes.
**Identifying a Security Group & Resource Owners/Sponsors:**
  Leveraging the `ManagedBy` attribute via PowerShell to track down the official sponsor or owner of a specific security group or corporate resource:
  ```powershell
  Get-ADGroup -Identity "Target_Security_Group" -Properties ManagedBy | Select-Object Name, ManagedBy
