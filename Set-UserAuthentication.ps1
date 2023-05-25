param (
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [string]$Module = "MSOnline",

    [Parameter(Mandatory = $false)]
    [string]$ErrorLogPath = (Join-Path -Path $env:USERPROFILE -ChildPath "Documents\error.log")
)

# Check execution policy and set if needed
$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($executionPolicy -ne "RemoteSigned" -and $executionPolicy -ne "Unrestricted") {
    Write-Host "Setting execution policy to RemoteSigned..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

# Check if module is installed and imported
if ($null -eq (Get-Module -Name $Module)[0]) {
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
        $UserPrincipalName = $user.UserPrincipalName
        $MobileNumber = $user.MobileNumber
        $AlternateMobiles = $user.AlternateMobileNumbers -split ","

        # Validate input data
        if ([string]::IsNullOrWhiteSpace($UserPrincipalName) -or [string]::IsNullOrWhiteSpace($MobileNumber)) {
            Write-Error "Invalid input data for UserPrincipalName or MobileNumber."
            continue
        }

        try {
            # Create new StrongAuthenticationMethod (SAM) objects
            $SAM1 = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
            $SAM2 = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
            $SAM3 = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
            $SAM4 = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod

            # Configure the StrongAuthenticationMethods
            $SAM1.IsDefault = $true          # Set SAM1 as the default method
            $SAM1.MethodType = "OneWaySMS"   # SAM1: One-way SMS
            $SAM2.IsDefault = $false         # SAM2 is not the default method
            $SAM2.MethodType = "PhoneAppOTP" # SAM2: Phone app OTP
            $SAM3.IsDefault = $false         # SAM3 is not the default method
            $SAM3.MethodType = "PhoneAppNotification" # SAM3: Phone app notification
            $SAM4.IsDefault = $false         # SAM4 is not the default method
            $SAM4.MethodType = "TwoWayVoiceMobile"    # SAM4: Two-way voice mobile

            $SAMethods = @($SAM1, $SAM2, $SAM3, $SAM4)

            # Set the StrongAuthenticationMethods for the user
            Set-MsolUser -UserPrincipalName $UserPrincipalName -StrongAuthenticationMethods $SAMethods `
                -MobilePhone $MobileNumber -AlternateMobilePhones $AlternateMobiles

            # Update progress
            $progress++
            Write-Progress -Activity "Processing users" -Status "Progress: $progress/$total" -PercentComplete (($progress/$total) * 100) -CurrentOperation "User: $UserPrincipalName"
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
