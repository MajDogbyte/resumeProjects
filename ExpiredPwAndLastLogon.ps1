# Check if PSWriteHTML module is installed
if (-not (Get-Module -ListAvailable -Name PSWriteHTML)) {
    # Module not found, so install it
    Write-Host "PSWriteHTML module not found. Installing..."
    Install-Module -Name PSWriteHTML -Scope CurrentUser -Force
    Import-Module -Name PSWriteHTML
}
else {
    # Module is already installed, so import it
    Import-Module -Name PSWriteHTML
}

#set the variables
$domain = "example.com"
$expireDate = (Get-Date).AddDays( - (Get-ADDefaultDomainPasswordPolicy $domain).MaxPasswordAge.TotalDays)

# Specify the Organizational Units (OUs) to search for users
$ous = @("OU=OU1,DC=example,DC=com", "OU=OU2,DC=example,DC=com", "OU=OU3,DC=example,DC=com", "OU=OU4,DC=example,DC=com")

# Initialize an empty array to store the user results
$users = @()

# Iterate over each OU and retrieve user information
ForEach ($ou in $ous) {
    $users += Get-ADUser -Filter { Enabled -eq $true } -searchbase $ou -Properties Name, PasswordExpired, LastLogonDate |
    Where-Object { $_.PasswordExpired -eq $true -or $_.LastLogonDate -lt $expireDate } |
    Select-Object Name, @{Name = "PasswordExpired"; Expression = { $_.PasswordExpired } }, LastLogonDate
}

# Output the final user results
#$users | Out-HtmlView -Title "Expired Passwords or Last Logon Date Past 180 Days" -FilePath "C:\users\jdoe\Documents\ExpiredPWandLastLogonDate.html"
$users | Out-HtmlView -Title "Expired Passwords or Last Logon Date Past 180 Days"