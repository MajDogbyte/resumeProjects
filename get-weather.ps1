# Convert unix time format to friend format
# (Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($unixTime))

# Set your API key
$apiKey = "YOUR-API-KEY"

# Define the geographical coordinates for different locations
$testGeoCoords = "34.894214, -92.080909"
$austin = "34.959271,-91.946198"
$adamsField = "34.730902, -92.230410"
$noaaCabot = "34.9818, -92.0064"
$cabot = "34.973608,-92.016863"

# Retrieve weather data from the Dark Sky API
$json = Invoke-WebRequest -Method get -Uri "https://api.darksky.net/forecast/$apiKey/$adamsField" -UseBasicParsing

# Convert JSON response to PowerShell object
$obj = ConvertFrom-Json -InputObject $json.Content

# Define custom properties for the forecast objects
$PropertiesObj = [PSCustomObject]@{
    Day      = @{l = "Day"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.time))).DayOfWeek } }
    Time     = @{l = "Time"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.time))) } }
    Pressure = "Pressure"
}

# Select the hourly forecast data for 48 hours
$forecastHourly48hr = $obj.hourly.data | Select-Object @{
    l = "Day"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.time))).DayOfWeek }
}, @{
    l = "Time"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.time))) }
}, Pressure, @{
    l = "PressureInInches"; e = { "{0:n2}" -f ($_.Pressure * 0.0295301) }
}

# Select the daily forecast data
$forecastDaily = $obj.daily.data | Select-Object  @{
    l = "Day"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.time))).DayOfWeek }
}, @{
    l = "Time"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.time))).ToShortDateString() }
}, @{
    l = "Min"; e = { $_.temperatureMin }
}, @{
    l = "RealFeelMin"; e = { $_.apparentTemperatureMin }
}, @{
    l = "MinTime"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.apparentTemperatureMinTime))).ToShortTimeString() }
}, @{
    l = "Max"; e = { $_.TemperatureMax }
}, @{
    l = "RealFeelMax"; e = { $_.apparentTemperatureMax }
}, @{
    l = "MaxTime"; e = { ((Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($_.temperatureMaxTime))).ToShortTimeString() }
}, Pressure, @{
    l = "PressureInInches"; e = { "{0:n2}" -f ($_.Pressure * 0.0295301) }
}, humidity, moonPhase, @{
    l = "Sum"; e = { $_.summary }
}

# Get the current weather data
$current = $obj.currently

# Print the hourly forecast table
$forecastHourly48hr | Format-Table

# Print the daily forecast details
$forecastDaily | Format-List

# Print the current weather data
$current

# Print the nearest station information
$obj.flags.'nearest-station'

# CSS stylesheet for HTML formatting
$css = @"
    /* CSS Styles */
"@

# Convert forecast data to HTML tables
$hourly = $forecastHourly48hr | ConvertTo-EnhancedHTMLFragment -As Table -PreContent '<h2>Hourly Forecast</h2>' -Properties Day, Time, Pressure, PressureInInches
$daily = $forecastDaily | ConvertTo-EnhancedHTMLFragment -As Table -PreContent '<h2>Daily Forecast</h2>' -Properties Time, Day, Humidity, Max, MaxTime, Min, MinTime, MoonPhase, Pressure, PressureInInches, RealFeelMax, RealFeelMin, Sum

# Create the HTML email body
$body = ConvertTo-EnhancedHTML -CssStyleSheet $css -HTMLFragments $daily, $hourly -Title 'Daily Forecast' -PreContent "<h1>Daily Weather</h1>" | Out-String

# Configure email parameters
$param = @{
    From       = "noreply@example.com"
    To         = "jdoe@example.com"
    Body       = $body
    BodyAsHtml = $true
    Subject    = "Test Wx Report"
    SmtpServer = "mail.example.com"
}

# Send the email
Send-MailMessage @param
