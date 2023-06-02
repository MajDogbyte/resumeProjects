function Set-DistributionGroupMember {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MemberSamAccountName,

        [switch]$AddMember,

        [switch]$RemoveMember
    )
	
    $Server = "Top AD Forest Server Name Here"

    $selectedGroups = @()

    do {
        $DistributionGroupName = Read-Host "Enter the name of the distribution group (or 'done' to finish): "

        if ($DistributionGroupName -eq "done") {
            break
        }

        # Get the distribution group objects that match the partial name
        $distributionGroups = Get-ADGroup -Filter "Name -like '*$DistributionGroupName*'" -Server $Server

        if ($distributionGroups.Count -eq 0) {
            Write-Host "No distribution groups found matching '$DistributionGroupName'."
            continue
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

        $selectedGroups += $selectedGroup
    } while ($true)

    if ($selectedGroups.Count -eq 0) {
        Write-Host "No distribution groups selected."
        return
    }

    foreach ($selectedGroup in $selectedGroups) {
        # Retrieve the members of the distribution group
        $members = Get-ADGroupMember -Identity $selectedGroup -Server $Server | Select-Object -ExpandProperty SamAccountName

        if ($AddMember) {
            # Search for users matching the provided SamAccountName
            $matchingMembers = $(Get-ADUser -Filter "SamAccountName -like '*$MemberSamAccountName*'" -Server $Server).SamAccountName

            if ($matchingMembers.Count -eq 0) {
                Write-Host "No users found matching '$MemberSamAccountName'."
                continue
            }

            $index = 1
            $selectedMember = $matchingMembers | ForEach-Object {
                Write-Host "$index. $($_)"
                $index++
            }

            $choice = Read-Host "Enter the number of the user to add to the distribution group (or 'done' to finish): "
            $choice = $choice -as [int]  # Cast the input as an integer
            $selectedMember = ($matchingMembers -split " ")[$choice - 1]

            if ($members -contains $selectedMember) {
                Write-Host "User '$selectedMember' is already a member of '$($selectedGroup.Name)'."
                continue
            }

            # Add the selected member to the distribution group
            Add-ADGroupMember -Identity $selectedGroup -Members $selectedMember -Server $Server
            Write-Host "User '$selectedMember' has been added to '$($selectedGroup.Name)'."
        }
        elseif ($RemoveMember) {
            if ($members.Count -eq 0) {
                Write-Host "The distribution group '$($selectedGroup.Name)' does not have any members."
                continue
            }

            $matchingMembers = $members | Where-Object { $_ -like "*$MemberSamAccountName*" }

            if ($matchingMembers.Count -eq 0) {
                Write-Host "No members found matching '$MemberSamAccountName'."
                continue
            }

            $index = 1
            $selectedMember = $matchingMembers | ForEach-Object {
                Write-Host "$index. $_"
                $index++
            }

            $choice = Read-Host "Enter the number of the member to remove from the distribution group: "
            $choice = $choice -as [int]  # Cast the input as an integer
            $selectedMember = ($matchingMembers -split " ")[$choice - 1]

            if ($members -notcontains $selectedMember) {
                Write-Host "User '$selectedMember' is not a member of '$($selectedGroup.Name)'."
                continue
            }

            # Remove the selected member from the distribution group
            Remove-ADGroupMember -Identity $selectedGroup -Members $selectedMember -server $Server -Confirm:$false
            Write-Host "User '$selectedMember' has been removed from '$($selectedGroup.Name)'."
        }
        else {
            Write-Host "Please specify either -AddMember or -RemoveMember switch."
        }
    }
}
