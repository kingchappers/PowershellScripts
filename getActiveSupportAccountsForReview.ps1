connect-msolservice

$users = get-msolUser -All

$supportusers = $users | where-object{$_.DisplayName -like "*.support*" -and $_.BlockCredential -like 'False'} | select-object DisplayName, BlockCredential

$supportusers | Export-Csv -Path .\supportAccounts.csv