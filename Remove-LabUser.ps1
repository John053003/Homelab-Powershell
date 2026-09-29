# Remove-LabUser.ps1
# Offboards a user: disables the account, removes group memberships,
# stamps the date in the description, and moves it to the Disabled Users OU.
# Usage:  .\Remove-LabUser.ps1 -Username cnguyen -WhatIf   (preview only)
#         .\Remove-LabUser.ps1 -Username cnguyen           (do it for real)

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Username
)

Import-Module ActiveDirectory

$DisabledOU = "OU=Disabled Users," + (Get-ADDomain).DistinguishedName
$User = Get-ADUser -Identity $Username -Properties MemberOf

Write-Host "Offboarding $($User.Name) ($Username)" -ForegroundColor Cyan

# 1. Disable the account so it can't sign in
Disable-ADAccount -Identity $User

# 2. Remove every group membership (show each one for the record)
foreach ($GroupDN in $User.MemberOf) {
    $GroupName = (Get-ADGroup -Identity $GroupDN).Name
    Write-Host "  Removing from group: $GroupName"
    Remove-ADGroupMember -Identity $GroupDN -Members $User -Confirm:$false
}

# 3. Leave a note on the account for auditors
$Today = Get-Date -Format "yyyy-MM-dd"
Set-ADUser -Identity $User -Description "Offboarded $Today"

# 4. Move it to the Disabled Users OU
Move-ADObject -Identity $User.DistinguishedName -TargetPath $DisabledOU

if ($WhatIfPreference) {
    Write-Host "WhatIf run - nothing was changed." -ForegroundColor Yellow
} else {
    Write-Host "$Username has been offboarded." -ForegroundColor Green
}
