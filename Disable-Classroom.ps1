function Disable-MFHClassroom {
    param(
        [string]$userName,
        [string]$UserAccountInactive,
        [string]$EmployeeID
    )
    
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
    
    # Call the web service method to update the inactive flag
    $result = $Proxy.updateInactiveFlag20100415($AccountLoginCode, $AccountXMLCode, $AccountIDSpecialCode, $Credentials.GetNetworkCredential().username, $Credentials.GetNetworkCredential().password, $UserAccountInactive, $userName)
    
    # If the result contains an error message, try updating using EmployeeID
    if ($result.Contains("Fail|Could not save, the Login Code cannot be found to update against.")) {
        $result = $Proxy.updateInactiveFlag20100415($AccountLoginCode, $AccountXMLCode, $AccountIDSpecialCode, $Credentials.GetNetworkCredential().username, $Credentials.GetNetworkCredential().password, $UserAccountInactive, $EmployeeID)
    }
    
    # Output the MFH Classroom status
    Write-Output "`nMFH Classroom Status: $result"
}