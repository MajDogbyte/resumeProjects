# Import the Active Directory module
Import-Module ActiveDirectory

# Function to change "Managed By" for a single distribution group
function Set-DistributionGroupManagedBy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DistributionGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ManagedByUser
    )
    
    # Get the distribution group objects that match the partial name
    $distributionGroups = Get-ADGroup -Filter "Name -like '*$DistributionGroupName*'"

    if ($distributionGroups.Count -eq 0) {
        Write-Host "No distribution groups found matching '$DistributionGroupName'."
        return
    }
    
    if ($distributionGroups.Count -gt 1) {
        # Prompt to select the correct distribution group
        $index = 1
        $selectedGroup = $distributionGroups | ForEach-Object {
            Write-Host "$index. $($_.Name)"
            $index++
        }
        
        $choice = Read-Host "Enter the number of the distribution group to update: "
        $selectedGroup = $distributionGroups[$choice - 1]
    }
    else {
        $selectedGroup = $distributionGroups[0]
    }
    
    # Get the correct managed by user object if the original one offered is not found. 
    if (-not (Get-ADUser -Identity $ManagedByUser)) {
        $managedBy = $null
    
        do {
            # Prompt for the user to change to
            $newUser = Read-Host "Enter the username of the new Managed By user: "
            $managedBy = Get-ADUser -Identity $newUser
        
            if ($null -eq $managedBy) {
                Write-Host "User '$newUser' not found. Please try again."
            }
        } while ($null -eq $managedBy)
    }
    else {
        $managedBy = Get-ADUser -Identity $ManagedByUser
        $newUser = $managedBy.DistinguishedName
    }
    
    
    # Change the managed by user for the selected distribution group
    Set-ADGroup -Identity $selectedGroup.Name -ManagedBy $managedBy.DistinguishedName
    Write-Host "Managed By user for '$($selectedGroup.Name)' set to '$newUser'."
}

# Usage example

# Change the managed by user for distribution groups containing the partial name
Set-DistributionGroupManagedBy -DistributionGroupName "partial_name" -ManagedByUser "username"
