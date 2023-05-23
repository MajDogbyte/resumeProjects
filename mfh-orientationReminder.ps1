# Setup email parameters
$priority = "High"
$smtpServer = "mail.example.com"
$emailFrom = "noreply@example.com"
$emailTo = "helpdesk@example.com"
$port = 25

# Load the data from the CSV file
$data = Import-Csv -Path "C:\Users\jdoe\Documents\orientationEvents.csv" -UseCulture

# Get the current date
$currentDate = Get-Date

# Get all events occurring within the next 7 days
$eventDates = $data | Where-Object { [datetime]::Parse($_.A) -ge $currentDate -and [datetime]::Parse($_.A) -lt ($currentDate.AddDays(7)) } | Select-Object A, B

# If there are events in the next 7 days
if ($eventDates) {

    # Construct the email message
    $subject = "Upcoming Event Notification"
    $body = "The following events are scheduled within the next 7 days:`n`n"

    foreach ($event in $eventDates) {
        $body += "$([datetime]::Parse($event.A).ToString('MM/dd/yyyy ddd')) - $($event.B)`n"
    }

    $body += "`nPlease be sure to set yourself a reminder."

    # Send the email
    Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $body -SmtpServer $smtpServer -Priority $priority -Port $port
}