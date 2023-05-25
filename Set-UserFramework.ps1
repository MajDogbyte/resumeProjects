param (
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [string]$Module = "MSOnline",

    [Parameter(Mandatory = $false)]
    [string]$ErrorLogPath = (Join-Path -Path $env:USERPROFILE -ChildPath "Documents\error.log")
)

# Check execution policy and set if needed
$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($executionPolicy -notin ("RemoteSigned", "Unrestricted")) {
    Write-Host "Setting execution policy to RemoteSigned..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

# Check if module is installed and imported
if (!(Get-Module -Name $Module)) {
    # Install module if it's not already installed
    Write-Host "Installing module $Module..."
    Install-Module -Name $Module -Force -AllowClobber
}
else {
    # Import module if it's already installed
    Write-Host "Importing module $Module..."
    Import-Module -Name $Module
}

# Prompt the user to log in if not already logged in
Connect-MsolService

try {
    # Read the CSV file
    $users = Import-Csv -Path $CsvPath

    # Progress tracking
    $progress = 0
    $total = $users.Count

    # Process each user in the CSV file
    foreach ($user in $users) {
        # Retrieve user information from the CSV
        #$UserPrincipalName = $user.UserPrincipalName
        #$MobileNumber = $user.MobileNumber
        #$AlternateMobiles = $user.AlternateMobileNumbers -split ","

        # Validate input data
        if ([string]::IsNullOrWhiteSpace($UserPrincipalName) -or [string]::IsNullOrWhiteSpace($MobileNumber)) {
            Write-Error "Invalid input data for UserPrincipalName or MobileNumber."
            continue
        }

        try {
            # DO STUFF HERE...

            # Update progress
            $progress++
            Write-Progress -Activity "Processing users" -Status "Progress: $progress/$total" -PercentComplete (($progress / $total) * 100) -CurrentOperation "User: $UserPrincipalName"
        }
        catch {
            # Log any errors encountered
            $errorMessage = "Error setting authentication methods for user '$UserPrincipalName'.`nError: $_"
            $errorMessage | Out-File -FilePath $ErrorLogPath -Append
            Write-Error $errorMessage
        }
    }

    # Completed
    Write-Host "Script execution completed."
}
catch {
    # Log any errors encountered during script execution
    $errorMessage = "An error occurred while processing the CSV file: $($_.Exception.Message)"
    $errorMessage | Out-File -FilePath $ErrorLogPath -Append
    Write-Error $errorMessage
}
