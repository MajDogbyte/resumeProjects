# Import the Active Directory module
Import-Module ActiveDirectory

# Function to change "Managed By" for all distribution groups matching a user
function Set-AllDistributionGroupsManagedBy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManagedByUser
    )
    
    # Get the managed by user object
    $managedBy = Get-ADUser -Identity $ManagedByUser
    
    if ($null -eq $managedBy) {
        Write-Host "User '$ManagedByUser' not found."
        return
    }
    
    do {
        # Prompt for the user to change to
        $newUser = Read-Host "Enter the username of the new Managed By user: "
        $newManagedBy = Get-ADUser -Identity $newUser
        
        if ($null -eq $newManagedBy) {
            Write-Host "User '$newUser' not found. Please try again."
        }
    } while ($null -eq $newManagedBy)
    
    # Get all distribution groups managed by the specified user
    $distributionGroups = Get-ADGroup -Filter { ManagedBy -eq $managedBy.DistinguishedName } -Properties ManagedBy -SearchBase "OU=Exchange Distribution Lists,DC=example,DC=com"
    
    if ($distributionGroups.Count -eq 0) {
        Write-Host "No distribution groups found for user '$ManagedByUser'."
        return
    }
    
    # Change the managed by user for each distribution group
    foreach ($distributionGroup in $distributionGroups) {
        $newManagedByDN = $newManagedBy.DistinguishedName
        $groupDN = $distributionGroup.DistinguishedName
        Set-ADGroup -Identity $groupDN -ManagedBy $newManagedByDN
        Write-Host "Managed By user for '$($distributionGroup.Name)' set to '$newUser'."
    }
}

# Usage example

# Change the managed by user for all distribution groups matching a user
Set-AllDistributionGroupsManagedBy -ManagedByUser "current_user" # Enter the current user to match the distribution groups
