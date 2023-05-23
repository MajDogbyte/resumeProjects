function Get-MFHClassroomInfo {
    # Define the URI for the web service
    $URI = "https://secure.test.com/webservices/ws_users.cfc?wsdl"
    
    # Create a new web service proxy object
    $Proxy = New-WebServiceProxy $URI -Namespace X
    
    # Set the account login codes
    [string]$AccountLoginCode = "YourAccountLoginCode"
    [string]$AccountXMLCode = "YourAccountLoginCode"
    [string]$AccountIDSpecialCode = "YourAPIkey"
    
    # Set the author login credentials
    $AuthorLogin = "AdminLoginNameLike-jdoe"
    $AuthorPassword = (Get-Content "C:\Classroom.txt" | ConvertTo-SecureString)
    $Credentials = New-Object System.Management.Automation.PSCredential ($AuthorLogin, $AuthorPassword)
    
    # Prompt the user to enter a unique user loginID
    $userName = Read-Host "Enter unique user loginID"
    
    # Define lookup codes for custom fields
    $CustomFieldWSCodes = @{
        "2833091" = "2833091 Lookup code for Annual Requirements Group"
        "3182982" = "3182982 Lookup code for Employee Location"
        "2829694" = "2829694 Lookup code for Employee Number"
    }
    
    # Output an empty line
    "" | Write-Output
    
    # Iterate over custom field codes
    foreach ($CustomFieldWSCode in $CustomFieldWSCodes.Keys) {
        # Output the custom field description
        Write-Output $($CustomFieldWSCodes.Item($CustomFieldWSCode))
        
        # Call the web service method to check custom field
        $result = $Proxy.checkCustomField20110426($AccountLoginCode, $AccountXMLCode, $AccountIDSpecialCode, $Credentials.GetNetworkCredential().username, $Credentials.GetNetworkCredential().password, $userName, $CustomFieldWSCode)
        
        # Output the result
        $result
        
        # Output an empty line
        "" | Write-Output
    }
}


