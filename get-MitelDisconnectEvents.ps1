#Create a Scheduled Job that runs every 15 minutes.
#Register-ScheduledJob -Name 'CheckMitel' -FilePath 'C:\users\jdoe\Documents\get-mitelEventLogs.ps1' -Trigger (New-JobTrigger -Once -At "5/5/2020 3:45pm" -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration ([TimeSpan]::MaxValue))


<# TimeCreated                  Id LevelDisplayName Message
---------- - -- ---------------- ------ -
5/4/2020 7:08:37 PM            233 Warning          TMS has disconnected from switch "SwitchName-SG50V" (192.168.x.x).  This may be as a result of a networ… #>

<# TimeCreated                     Id LevelDisplayName Message
-----------                     -- ---------------- -------
5/5/2020 9:33:21 AM            234 Information      TMS has connected to switch "SwitchName-SG50V" (192.168.x.x). #>

# Down and Up events are captured as exampled above in the variables $downEvents and $upEvents. Each down event SHOULD be followed by a matching up event.
# ie. for each eventID#233 there should be at least one eventID#234 that matches for that location (shoretel switch).



# level 2 = errors, level 3 = warnings, level 4 = information
# $(get-date).AddDays(-1) equals "now minus 24 hours"
$downEvents = Get-WinEvent -ComputerName connect @{logname = 'application'; level = 3; id = 233; StartTime = $(get-date).AddMinutes(-15) } -ErrorAction SilentlyContinue;
$upEvents = Get-WinEvent -ComputerName connect @{logname = 'application'; level = 4; id = 234; StartTime = $(get-date).AddMinutes(-15) } -ErrorAction SilentlyContinue;

# Each time we detect a down event WITHOUT a matching up event. We will restart-ShoretelTMS64 regardless if there is only 1 flag vs multiple
$flags = $null;

if (-not ($null -eq $downEvents -or $null -eq $upEvents) ) {

  # loop through each DOWN event so we can then compare to each existing UP event.
  foreach ($downEvent in $downEvents) {
    # splitting each event message on the double quote character, gives us a 3 member array, leaving only the location name at the arrays[1] position.
    $location = $downEvent.message.Split('"')[1]; # outputs SwitchName-SG50V
    # capture the date of this down event so we can compare to each up event later.
    $downDate = $downEvent.TimeCreated;


    foreach ($upEvent in $upEvents) {
      # Go through the list of each upEvents.

      if ( (-not $upEvent.message -match $location) -or ( $upEvent.message -match $location -and $upEvent.TimeCreated -lt $downDate) ) {
        # if scenario 1 or scenario 2 is TRUE then add the location for this particular downevent into the Flags variable
        $flags += $location
        $flags
      }
    }
  }

}




# splatting for storing parameters for write-eventlog.
# These will be the common parameters on each write-eventlog. Others will be added as needed.
# must register new eventlog source with  New-EventLog -Source C:\users\jdoe\Documents\get-mitelEventLogs.ps1 -LogName Application
# Write-eventlog family of cmdlets doesnt exist past $psversiontable > 5.1. ie. not for PS6 or PS7
$parameters = @{

  'LogName' = 'Application'

  'Source'  = '.\get-mitelEventLogs.ps1'

}







if ($null -eq $flags) {
  # If no flags, do nothing

  $parameters += @{

    'EventId'   = 1

    'EntryType' = 'Information'

    'Message'   = 'No orphaned down events detected for any Mitel switches.'

  }

  Write-EventLog @parameters
}
else {
  # otherwise "restart-service Shoretel-TMS64"

  try {
    Restart-Service -Name ShoreTel-TMS64;

    $parameters += @{

      'EventId'   = 2

      'EntryType' = 'Warning'

      'Message'   = "Orphaned down event/s detected for: $($flags -join ","). Restart-Service Shoretel-TMS64 ran!"

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

  }
}