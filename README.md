# Home Lab PowerShell – Active Directory Automation

PowerShell scripts I wrote to automate user onboarding and offboarding in Active Directory.
Built and tested in my own Azure home lab.

## Lab environment
- **Azure** virtual network with separate server and client subnets, no public IPs, access through Azure Bastion
- **dc01** – Windows Server 2022 domain controller (AD DS + DNS) for `homelab.local`
- **client01** – domain-joined Windows Server client managed by Group Policy
- **linux01** – Ubuntu 24.04 server running nginx, using the domain's DNS

## Scripts

### New-LabUsers.ps1 – Onboarding
Creates user accounts in bulk from a CSV file and adds each user to a security group.
- Skips users that already exist, so it's safe to run more than once
- Prompts for the starting password at runtime (no passwords stored in the script)
- Forces a password change at first sign-in

```powershell
.\New-LabUsers.ps1
```
Uses `newhires-sample.csv` for input (columns: FirstName, LastName, Username, Department, Group).

### Remove-LabUser.ps1 – Offboarding
Disables an account, removes all of its group memberships, stamps the offboarding date,
and moves it to a Disabled Users OU.
- Supports `-WhatIf` to preview every change before making it
- Lists each group removed, so access can be restored if needed

```powershell
.\Remove-LabUser.ps1 -Username jdoe -WhatIf   # preview
.\Remove-LabUser.ps1 -Username jdoe           # run
```

## What I learned
- Splatting, parameters, and `SupportsShouldProcess` for safe, reusable scripts
- Why companies disable accounts instead of deleting them
- Troubleshooting AD dependencies: DNS, group membership, and Group Policy
