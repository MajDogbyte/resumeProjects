function ScanFor {
    param(
        $username,
        $computername
    )

    # Check if running PowerShell 5 or later
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "This function requires PowerShell 5 or later."
        return
    }

    # Initialize variables
    $scan = $null

    # Perform parallel scan using Invoke-Parallel
    $scan = Invoke-Parallel -InputObject $(Get-ADComputer -Filter * -SearchBase "OU=Domain Workstations,DC=example,DC=com").name -ScriptBlock {
        invoke-command -computerName $_ -command { 
            "[$env:COMPUTERNAME]:"; 
            quser 
        }
    } -Throttle 100 -ErrorAction SilentlyContinue -RunspaceTimeout 10

    # Convert the scan results to JSON and then back to objects
    $converted = $scan | ConvertTo-Json | ConvertFrom-Json

    # Filter the results based on the provided username or computername
    if ($username) {
        $username = "*" + $username + "*"
        $converted | Select-Object value, pscomputername | Where-Object { $_.value -like $username }
    }
    else {
        $computername = "*" + $computername + "*"
        $converted | Select-Object value, pscomputername | Where-Object { $_.pscomputername -like $computername }
    }
}
