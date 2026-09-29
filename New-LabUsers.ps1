# New-LabUsers.ps1
# Creates Active Directory users from a CSV file and adds each one to a group.

Import-Module ActiveDirectory

$CsvPath  = "C:\Scripts\newhires.csv"
$Domain   = "homelab.local"
$TargetOU = "OU=Employees," + (Get-ADDomain).DistinguishedName

# Ask for a starting password without showing it on screen
$Password = Read-Host "Starting password for new users" -AsSecureString

$NewHires = Import-Csv -Path $CsvPath

foreach ($Hire in $NewHires) {

    # Skip anyone who already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$($Hire.Username)'") {
        Write-Warning "$($Hire.Username) already exists - skipping."
        continue
    }

    # Collect the settings in one place (called "splatting")
    $UserSettings = @{
        Name                  = "$($Hire.FirstName) $($Hire.LastName)"
        GivenName             = $Hire.FirstName
        Surname               = $Hire.LastName
        SamAccountName        = $Hire.Username
        UserPrincipalName     = "$($Hire.Username)@$Domain"
        Department            = $Hire.Department
        Path                  = $TargetOU
        AccountPassword       = $Password
        ChangePasswordAtLogon = $true
        Enabled               = $true
    }
    New-ADUser @UserSettings

    Add-ADGroupMember -Identity $Hire.Group -Members $Hire.Username

    Write-Host "Created $($Hire.Username) and added to $($Hire.Group)" -ForegroundColor Green
}
