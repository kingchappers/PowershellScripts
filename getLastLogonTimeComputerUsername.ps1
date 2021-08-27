$dcs = Get-ADComputer -Filter { OperatingSystem -NotLike '*Server*' } -Properties OperatingSystem

foreach($dc in $dcs) { 
    Get-ADComputer $dc.Name -Properties lastlogontimestamp | 
    Select-Object @{n="Computer";e={$_.Name}}, @{Name="Lastlogon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
}