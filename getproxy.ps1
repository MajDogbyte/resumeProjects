function Get-Proxy {
    $reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    # Retrieve the Internet Settings registry key
    $settings = Get-ItemProperty -Path $reg

    # Extract the ProxyServer and ProxyEnable properties from the settings
    $proxyServer = $settings.ProxyServer
    $proxyEnabled = $settings.ProxyEnable

    # Check if a proxy server is enabled
    if ($proxyEnabled -eq 1) {
        # If a proxy is enabled, return the server address
        Write-Output "Proxy Server: $proxyServer"
    }
    else {
        # If proxy is not enabled, inform the user
        Write-Output "Proxy is not enabled."
    }
}

# Call the function to retrieve and display the proxy settings
Get-Proxy

