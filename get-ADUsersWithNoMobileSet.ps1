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
# Specify the OUs to check
$ous = @("OU=Fillmore Users,DC=example,DC=com", "OU=Maumelle Users,DC=example,DC=com", "OU=Admin Users,DC=example,DC=com", "OU=Methodist Counseling Clinic Users,DC=example,DC=com")

# Create an empty array to store the results
$usersWithoutMobile = @()

# Iterate through each OU
foreach ($ou in $ous) {
    # Get the users without the mobile property in the OU
    $users = Get-ADUser -Filter { (mobilephone -notlike '*') -and (Enabled -eq $true) -and (ObjectClass -eq 'user') } -SearchBase $ou -Properties DisplayName, EmailAddress, CanonicalName, DistinguishedName

    # Iterate through each user
    foreach ($user in $users) {
        # Extract the OU name from the CanonicalName
        $ouName = $user.CanonicalName -replace "^.*?/", ""

        # Create a custom object with the desired properties
        $customObject = [PSCustomObject]@{
            FullName     = $user.DisplayName
            EmailAddress = $user.EmailAddress
            OUName       = $ouName
        }

        # Add the custom object to the array
        $usersWithoutMobile += $customObject
    }
}

# Output the results
$usersWithoutMobile | Out-HTMLView -Title "Users with blank mobile phone property."
