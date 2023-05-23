# Invokes a command on a remote computer using specified credentials
function New-InvokeCommand {
    param(
        [string]$ComputerName,
        [string]$Command
    )

    # Create a script block from the command string
    $ScriptBlock = [scriptblock]::Create($Command)

    # Specify the username and password for authentication
    $Username = "username.admin"
    $CredentialFile = "C:\invokecommand.txt"
    $Password = Get-Content $CredentialFile | ConvertTo-SecureString
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password

    # Invoke the command on the remote computer
    Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -Credential $Credential
}

# Sets a hashed password by converting it to a secure string and storing it in a file
function Set-HashedPW {
    param(
        [string]$Password,
        [string]$Path
    )

    # Convert the password to a secure string
    $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force

    # Convert the secure string to an encrypted string and save it to a file
    $SecurePassword | ConvertFrom-SecureString | Out-File -FilePath $Path
}
