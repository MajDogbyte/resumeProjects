function Send-toTeams {

    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Teams Channel 1', 'Teams Channel 2')]
        $webhook, # Specifies the type of webhook to use: 'Teams Channel 1' or 'Teams Channel 2'

        [Parameter(Mandatory = $true)]
        $text       # The text message to send to Teams
    )

    switch ($webhook) {
        'Teams Channel 1' { $newWebhook = "https://example.webhook.office.com/webhookb2/enter-your-webhookurl-between-the-quotes" }   # Set the appropriate webhook link for 'Teams Channel 1'
        'Teams Channel 2' { $newWebhook = "https://example.webhook.office.com/webhookb2/enter-your-webhookurl-between-the-quotes" }           # Set the appropriate webhook link for 'Teams Channel 2'
        Default {}                                                                  # Default case for unrecognized webhook types
    }

    $payload = @{
        "text" = $text   # Construct the payload with the provided text message
    }
    $json = ConvertTo-Json $payload   # Convert the payload to JSON format

    try {
        Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $json -Uri $newWebhook   # Send the payload to the specified webhook
    }
    catch {
        Write-Host "An error occurred while sending the message to Teams. Error details: $_"
    }
}
