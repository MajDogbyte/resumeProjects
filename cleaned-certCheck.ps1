# Set the list of website URLs and email settings
$urlList = @("https://site1.example.com", "https://site2.example.com", "https://site3.example.com:9251", "https://mail.example.com", "https://exchange-server.example.com")
# Setup email parameters
$priority = "Normal"
$smtpServer = "mail.example.com"
$emailFrom = "noreply@example.com"
$emailTo = "jdoe@example.com"
$cc = "djay@example.com"
$port = 25


# Loop through the list of URLs and check their certificates
foreach ($websiteUrl in $urlList) {
    $hostName = $websiteUrl.Replace("https://", "").Replace("http://", "")
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient($hostName, 443)
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
        $sslStream.AuthenticateAsClient($hostName)
        $certificate = $sslStream.RemoteCertificate
    }
    catch {
        $certificate = $null
    }
    if ($null -ne $certificate) {
        # Check if the certificate will expire in the next N days
        $expiryDate = $certificate.GetExpirationDateString()
        Write-Host "Expiry date for $websiteUrl is: $expiryDate"
        $expiryDateTime = [datetime]::Parse($expiryDate)
        $daysUntilExpiry = ($expiryDateTime - (Get-Date)).Days
        $expiryWarningDays = 60

        if ($daysUntilExpiry -le $expiryWarningDays) {
            # Send an email with the results
            $subject = "Website certificate for $websiteUrl will expire in $daysUntilExpiry days"
            $body = "The website certificate for $websiteUrl will expire on $expiryDate. Please renew the certificate before it expires."
            Send-MailMessage -To $emailTo -Cc $cc -Subject $subject -BodyAsHtml $body  -SmtpServer $smtpServer -Port $port -From $emailFrom -Priority $priority
        }
    }
}