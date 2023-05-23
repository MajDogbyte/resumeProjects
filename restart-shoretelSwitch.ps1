function Restart-ShoretelSwitch {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' })]
        [string]$switchIP
    )

    try {
        # Prompt for credentials to be used for the remote connection
        $credential = Get-Credential

        # Connect to the ShoreTel switch and reboot it
        Invoke-Command -ScriptBlock {
            Set-Location -Path "C:\Program Files (x86)\Shoreline Communications\ShoreWare Server"
            ipbxctl -pw ShoreTel -reboot $using:switchIP | Out-Null
        } -Credential $credential
    }
    catch {
        Write-Error "Failed to restart ShoreTel switch. Error: $_"
    }
}
