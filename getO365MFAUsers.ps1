# Run in PowerShell v5
connect-MsolService

$MFAUsers = @()
$Users = Get-MsolUser -All | Where-Object { $_.UserType -ne "Guest" -and $_.BlockedCredential -ne $True -and $_.IsLicensed -eq $True } | Select-Object displayName, StrongAuthenticationRequirements, WhenCreated

ForEach ($User in $Users) {
    # $User | Select-Object displayName, StrongAuthenticationRequirements
    if(!$User.StrongAuthenticationRequirements){
        $User | Add-Member -NotePropertyName MFAUser -NotePropertyValue "Disabled"

        Write-Output $User.StrongAuthenticationRequirements.State
    } else {
        $User | Add-Member -NotePropertyName MFAUser -NotePropertyValue $User.StrongAuthenticationRequirements.State

    }
    $MFAUsers += $User
    # $User | Export-Csv -Path .\usersO365MFAReport.csv -Append
}

$MFAUsers | Export-Csv -Path .\usersO365MFAReport.csv

