function Send-Email {
    param (
        [string]$To,
        [string]$Subject,
        [string]$Body,
        [string]$Priority = "Normal",
        [string]$SmtpServer = "mail.example.com",
        [string]$From = "noreply@example.com",
        [int]$Port = 25
    )

    # Send the email
    Send-MailMessage -To $To -Subject $Subject -BodyAsHtml $Body -SmtpServer $SmtpServer -Port $Port -From $From -Priority $Priority -Cc "jdoe@example.com"
}

# Set up email parameters
$subject = "I am the subject"
$priority = "Normal"
$smtpServer = "mail.example.com"
$emailFrom = "noreply@example.com"
$emailTo = "jdoe@example.com"
$port = 25

# Call the function to send the email
Send-Email -To $emailTo -Subject $subject -Body $body -SmtpServer $smtpServer -Port $port -From $emailFrom -Priority $priority -Cc "jdoe@example.com"
