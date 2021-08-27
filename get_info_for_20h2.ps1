<#Steps to run 
1. Run Script from the local user directory (C:\Users\myusername)
#>

Connect-MsolService
Connect-AzAccount

#grab all devices from AAD
Write-Output "Getting Device List" 
$devices = Get-msoldevice -all -ReturnRegisteredOwners | Where-Object {($_.DeviceTrustType -eq "Domain Joined" -and $_.DeviceOSType -like "Windows*" -and $_.Enabled -eq "True")}

#grab all users from AAD
Write-Output "Getting User List" 
$users = get-msolUser -All

$numberofDevices = $devices.count 
$i = 0

#does log analytics query to get all update status' for devices
Write-Output "Getting Log Analytics Data"
$logAnalyticsData = Invoke-AzOperationalInsightsQuery -WorkspaceId "08dc2c10-9f18-48fc-acda-c8c0c525778f" -Query "WaaSDeploymentStatus | where UpdateCategory == 'Feature' and TargetOSVersion == '20H2' and (OSServicingBranch == 'Semi-Annual' or OSServicingBranch == 'Semi-Annual (Targeted)') | where TimeGenerated > ago(23h)"

$collection = [pscustomobject]@()

foreach($device in $devices) { 
    $i++
    $percentComplete = ($i / $numberofDevices) * 100
    Write-Progress -Activity "Processed: $i of $numberofDevices devices" -PercentComplete $percentComplete

    #Get the properties of the device from AAD. Then construct a table with the fields I want
    $deviceData = $device | Select-Object DisplayName, RegisteredOwners, ApproximateLastLogonTimestamp

    #Get the upgrade status data for the current device from the log analytics data 
    $updateStatus = $logAnalyticsData.results | where-object {$_.Computer -eq $device.DisplayName } | Select-Object Computer, DetailedStatus, OSVersion, TimeGenerated

    #A new record is added when the log analytics report runs each day, this could result in 2 sets of report data. This counteracts this by
    #sorting the status' by date and selects the last one which is the most recent
    $updateStatus = $updateStatus | Foreach-Object {$_.TimeGenerated = [DateTime]$_.TimeGenerated; $_} | Sort-Object TimeGenerated | Select-Object -Last 1

    #check if registered owner is populated
    if($deviceData.RegisteredOwners[0] -ne ""){
        #deviceData.RegisteredOwners is a List`1 object
        $userLocation = $users | Where-Object{$_.UserPrincipalName -eq $deviceData.RegisteredOwners[0]} | select-object Department, Office
    }
    else{
        $userLocation = [pscustomobject] @{
            Department = "No user data found"
            Office = "No user data found"
        }
    }

    #Create a new object that contains the device information and the upgrade status
    foreach($object in $deviceData){
        $collection += [pscustomobject] @{
            Computer = $deviceData.DisplayName
            DeviceOwner = $deviceData.RegisteredOwners[0]
            Department = $userLocation.Department
            Office = $userLocation.Office
            LastLogonTime = $deviceData.ApproximateLastLogonTimestamp
            DetailedStatus = $updateStatus.DetailedStatus
            OSVersion = $updateStatus.OSVersion
            TimeUpdateLogGenerated = $updateStatus.TimeGenerated
        }
    }
}

#Export the $collection object to a csv file, with the current date in the name, in the current directory
$collection | Export-Csv -Path .\UpdateStatus_$((Get-Date).ToString("yyyy-MM-dd")).csv
