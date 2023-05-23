#dot source our MS Teams function
. C:\users\jdoe\Documents\Send-toTeams.ps1

#Create a Scheduled Job that runs every 15 minutes.
#Register-ScheduledJob -Name 'Restart Shoretel-TMS64' -FilePath 'C:\users\jdoe\Documents\Restart-ShoretelTMS64.ps1' -Trigger (New-JobTrigger -Once -At "6/1/2020 1:30pm" -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration ([TimeSpan]::MaxValue))

$parameters = @{
    'LogName' = 'Application'
    'Source'  = 'C:\Users\jdoe\Documents\Restart-ShoretelTMS64.ps1'
}


try {
    Restart-Service -Name ShoreTel-TMS64;
    $parameters += @{
        'EventId'   = 1
        'EntryType' = 'Information'
        'Message'   = "Restart-Service Shoretel-TMS64 ran!"
}
    Write-EventLog @parameters
}
catch {

    $parameters += @{
        'EventId'   = 4
        'EntryType' = 'Error'
        'Message'   = "$Error[0].InvocationInfo"
}
    Write-EventLog @parameters

    Send-toTeams -webhook 'Network Outages' -text "Restart-ShoretelTMS64 blew up! >> $Error[0].InvocationInfo "

}
