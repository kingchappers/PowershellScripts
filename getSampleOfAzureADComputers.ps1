#Initialise a new ArrayList - These are best for large data sets - Read more online
$computerNameArray = [System.Collections.ArrayList]::new()

#Connect to AzureAD service
Connect-MsolService

#Get all endopoints in the modern workplace OU and iterate over all of the objects adding them to the list object $computerNameArray
Get-msoldevice -all | Where-Object {($_.DeviceTrustType -eq "Domain Joined" -and $_.DeviceOSType -like "Windows*")} | ForEach-Object{
    $computerName=$_.DisplayName

    #Basic status output of the process
    $i = $computerNameArray.count 
    Write-Progress -Activity "Processed computer count: $i" "Currently Processing: $computerName"

    #Add computer name to the ArrayList
    if($computerName -notlike '*UKS*' -And $computerName -notlike '*Windows*' -And $computerName -notlike '*MDT*'){
        [void]$computerNameArray.Add($computerName)
    }

}

Write-Host "Number of hosts found:"
Write-Host $computerNameArray.count

#Calculate 10% of the devices and round to the nearest whole
$numberOfComputersToScan = [math]::Round($computerNameArray.count * 0.1)

Write-Host "Number of hosts in sample (10%):"
write-Host $numberOfComputersToScan

#Pick from the list object the hosts that we'll scan
$computersToScan = Get-Random -InputObject $computerNameArray -Count $numberOfComputersToScan


#check for the existence of the text file and delet if it exists
$fileName = ".\computersToScan.txt"
if(Test-Path $fileName){
    Remove-Item $fileName
}

$computersToScan | Set-Content -Path "computersToScan.txt"
