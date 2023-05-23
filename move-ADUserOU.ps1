# This function is used to change the organizational unit (OU) of a user in Active Directory.

function move-UserOu {
    param (
        [Parameter(Mandatory = $true)]
        [string]$samAccountName, # The SAM account name of the user to be moved.

        [string]$server = "domainControllerHostname", # The hostname of the domain controller. Default is "domainControllerHostname".

        [Parameter(Mandatory = $true)]
        [ValidateSet('OU1', 'OU2', 'OU3', 'OU4', 'OU5')]
        [string]$targetOU  # The target OU where the user will be moved.
    )

    # Maps the target OU to the corresponding distinguished name (DN) value.
    switch ($targetOU) {
        'Site1' { $realTargetOU = "OU=OU1, DC=example, DC=com" }
        'Site2' { $realTargetOU = "OU=OU2,DC=example,DC=com" }
        'Site3' { $realTargetOU = "OU=OU3, DC=example, DC=com" }
        'Site4' { $realTargetOU = "OU=NestedOU4, OU=OU1, DC=example, DC=com" }
        'Site5' { $realTargetOU = "OU=OU5, DC=example, DC=com" }
        Default { $realTargetOU = "OU=OU3, DC=example, DC=com" }  # Default target OU if no match is found.
    }

    # Set the parameters for retrieving the user's properties.
    $params = @{
        Server     = $server
        Identity   = $samAccountName
        Properties = "DisplayName", "GivenName", "Surname", "PasswordLastSet", "Enabled", "AccountExpirationDate", "SamAccountName"
    }

    # Get the user to be moved based on the provided parameters.
    $userToMove = Get-ADUser @params

    # Move the user to the target OU.
    $userToMove | Move-ADObject -TargetPath $realTargetOU -Server $server

    # Display a message indicating the user's move.
    Write-Host "Moving $($userToMove.Name) from $($userToMove.DistinguishedName -split ",")[1] TO $($realTargetOU -split "," | Select-Object -First 1)..."

    # Retrieve the properties of the moved user.
    get-ADUser @params | Select-Object AccountExpirationDate, DisplayName, DistinguishedName, Enabled, PasswordLastSet, SamAccountName, UserPrincipalName

    # Display a "Done!" message in green color to indicate successful completion.
    Write-Host "Done!" -ForegroundColor Green
}



    