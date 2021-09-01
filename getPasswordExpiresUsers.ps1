#This gets a list of people who's passwords expire
#In line with the NCSC's guidance passwords should not expire for users

Connect-AzureAD

$collection = [pscustomobject]@()

$users = Get-AzureADUser -All $true | Where-Object {($_.PasswordPolicies -ne "DisablePasswordExpiration" -And $_.AccountEnabled -eq $True)} | Select-Object UserPrincipalName, PasswordPolicies, AccountEnabled, AssignedLicenses

$users | ForEach-Object {
    if($_.UserPrincipalName -notlike '*newsigsupport*' -And $_.UserPrincipalName -notLike '*#EXT#*' -And $_.AssignedLicenses.count -gt 0){
        $collection += [pscustomobject] @{
            UserPrincipalName = $_.UserPrincipalName
            PasswordPolicies = $_.PasswordPolicies
            AccountEnabled = $_.AccountEnabled
        }
    }

}

$collection

Write-Host "Number of users found:"
Write-Host $collection.count

