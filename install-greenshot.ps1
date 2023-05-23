Function Install-Greenshot {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]$ComputerName
    )
    Begin {
        # Copy psexec if it doesn't exist on this machine @ C:\SysinternalsSuite
        if (!(Test-Path -Path C:\SysinternalsSuite)) {
            try {
                New-Item -ItemType Container -Name SysinternalsSuite -Path "\\$env:COMPUTERNAME\c$" -Force
                Copy-Item -Path "\\networkShare\SysinternalsSuite\psexec.exe" -Destination "\\$env:COMPUTERNAME\c$\SysinternalsSuite"
            }
            catch {
                Write-Host "Could not create SysinternalsSuite folder setup."
                $PSItem.invocationinfo | Format-List *
            }
        }

        foreach ($computer in $ComputerName) {
            $result = winrm id -r:$computer 2> $null

            if ($lastExitCode -eq 0) {
                Write-Host "WinRM already enabled on" $computer "..." -ForegroundColor Green
            }
            else {
                Write-Host "Enabling WinRM on" $computer "..." -ForegroundColor Red
                C:\SysinternalsSuite\PsExec.exe \\$computer -s C:\Windows\System32\winrm.cmd qc -quiet

                if ($LastExitCode -eq 0) {
                    C:\SysinternalsSuite\psservice.exe \\$computer restart WinRM
                    $result = winrm id -r:$computer 2>$null

                    if ($LastExitCode -eq 0) {
                        Write-Host "WinRM successfully enabled!" -ForegroundColor Green
                    }
                    else {
                        exit 1
                    }
                } #end of if
            }
        }
    }

    Process {
        Write-Host "WinRM LastExitCode: $lastExitCode"

        foreach ($computer in $ComputerName) {
            $destinationFolder = "\\$computer\c$\" 

            # This section will copy the $sourcefile to the $destinationfolder. If the folder does not exist, it will create it.
            
            $DCpath = "\\example.com\NETLOGON\files\Greenshot"
            
            try {
                Write-Host "Testing network path to $computer" -ForegroundColor Yellow
                if (Test-Path "filesystem::\\$computer\c$\windows\temp") {
                    Write-Host "$computer found.." -ForegroundColor Green
                }
            }
            catch {
                Write-Host "Computer path not found"
                $PSItem.invocationinfo | Format-List *
            }
            
            try {
                if (!(Test-Path "filesystem::\\$computer\c$\Greenshot")) {
                    Write-Host "Starting file copy to $computer..." -ForegroundColor Green
                    Copy-Item -Recurse -Path $DCpath -Destination $destinationFolder
                    Write-Host "Copy from $DCpath to $destinationFolder done..." -ForegroundColor Green
                }
                else {
                    Write-Host "Greenshot already exists @\\$computer\c$\Greenshot..." -ForegroundColor Green
                }
            }
            catch {
                Write-Host "Could not copy for some reason!!"
                $PSItem.invocationinfo | Format-List *
            }
        }
    }
    
    End {
        try {
            Write-Host "Install Process begins..." -ForegroundColor Yellow
            Invoke-Command -ComputerName $computer -ScriptBlock {
                try {
                    $shell = New-Object -ComObject WScript.Shell
                    # Adding the shortcut to the public desktop folder will place it
                    # on all users' desktops.
                    $shortcut = $shell.CreateShortcut("C:\Users\Public\Desktop\Green Shot.lnk")
                    $shortcut.TargetPath = "C:\Greenshot\greenshot.exe"
                    $shortcut.IconLocation = $shortcut.TargetPath
                    $shortcut.Save()
                    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell)
                    Write-Host "Install Processed successfully..."
                }
                catch {
                    Write-Host "Error while running icon install command.."
                    $PSItem.invocationinfo | Format-List *
                }
            }
        }
        catch {
            Write-Host "Error while running Invoke-Command install command.."
            $PSItem.invocationinfo | Format-List *
        }
    }
}
