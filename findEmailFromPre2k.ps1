##Run this script from the directory with the list of pre2k names in it

$names = Import-csv .\names.csv
$emails = @()
foreach ($name in $names){
    $pre2k = $name.pre2k
    $emails += Get-ADUser -Identity $pre2k | Select-Object UserPrincipalName
    }

$emails
$emails | Export-Csv -Path .\emailsFromList.csv