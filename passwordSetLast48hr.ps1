$date = ((Get-Date).AddHours(-48)).ToString('g')
Get-ADUser -Filter "(passwordlastset -gt '$date')"? -Property passwordlastset | select name,passwordlastset