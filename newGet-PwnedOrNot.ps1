function Get-PwnedOrNot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $pass,
        [Parameter()]
        [string] $csvFile
    )

    try {
        # Check if a CSV file is provided
        if ($csvFile) {
            # Read the CSV file
            $csvData = Import-Csv $csvFile

            # Iterate over each row in the CSV
            foreach ($row in $csvData) {
                $email = $row.Email
                $hashedPassword = $row.Password

                # Process each row separately
                Process-Row $email $hashedPassword
            }
        }
        else {
            # Calculate the hash of the provided plain text password
            $powershellVersion = $PSVersionTable.PSEdition

            if ($powershellVersion -eq "Core") {
                # If PowerShell Core, use the SHA1 hash computation
                $hashBytes = [System.Text.Encoding]::UTF8.GetBytes($pass)
                $sha1 = [System.Security.Cryptography.SHA1]::Create()
                $hashedPassword = [System.BitConverter]::ToString($sha1.ComputeHash($hashBytes)).Replace('-', '')
            }
            else {
                # If regular PowerShell, use the SHA1 hash computation via .NET method
                $hashBytes = [System.Text.Encoding]::UTF8.GetBytes($pass)
                $sha1 = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
                $hashedPassword = [System.BitConverter]::ToString($sha1.ComputeHash($hashBytes)).Replace('-', '')
            }

            # Process the single password
            Process-Row "" $hashedPassword
        }
    }
    catch {
        # Handle any errors that occur during the API call
        Write-Error "Error calling HIBP API"
        return $null
    }
}

function Process-Row {
    param (
        [string] $email,
        [string] $hashedPassword
    )

    # Construct the API endpoint URL using the first 5 characters of the hash
    $uri = "https://api.pwnedpasswords.com/range/$($hashedPassword.Substring(0,5))"

    # Invoke the REST API and retrieve the list of hashes
    $powershellVersion = $PSVersionTable.PSEdition
    if ($powershellVersion -eq "Core") {
        $response = Invoke-RestMethod -Uri $uri -Method GET
    }
    else {
        $response = (Invoke-WebRequest -Uri $uri -Method GET).Content
    }

    # Split the response into separate lines
    $list = -split $response

    # Search for the hash suffix in the list of hashes
    $pwn = $list | Select-String $hashedPassword.Substring(5, 35)

    if ($pwn) {
        # If the hash suffix is found, extract the count of occurrences
        $count = [int]($pwn.ToString().Split(':')[1])
        Write-Host "The password for email '$email' has been pwned $count times. It is not secure and should not be used."
    }
    else {
        # If the hash suffix is not found, set the count to 0
        $count = 0
        Write-Host "The password for email '$email' has not been pwned. It is secure to use."
    }

    return $count
}
