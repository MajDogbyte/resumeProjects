function Enable-WinRM {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Computers
    )

    # Check if PSExec.exe exists, download if necessary
    $psexecPath = "C:\SysinternalsSuite\PsExec.exe"
    if (-not (Test-Path $psexecPath)) {
        Write-Host "PSExec.exe not found. Downloading PSExec.exe..." -ForegroundColor Cyan
        $url = "https://live.sysinternals.com/psexec.exe"
        $outputPath = Join-Path $psexecPath "..\psexec.exe"
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Move-Item -Path $outputPath -Destination $psexecPath
        Write-Host "PSExec.exe downloaded successfully!" -ForegroundColor Green
    }

    foreach ($computer in $Computers) {
        # Check if WinRM is already enabled
        $result = winrm id -r:$computer 2> $null
        if ($lastExitCode -eq 0) {
            Write-Host "WinRM already enabled on $computer..." -ForegroundColor Green
        }
        else {
            Write-Host "Enabling WinRM on $computer..." -ForegroundColor Red

            # Enable WinRM using PSExec.exe
            Set-Location C:\SysinternalsSuite
            & .\PsExec.exe \\$computer -s C:\Windows\System32\winrm.cmd qc -quiet

            if ($LastExitCode -eq 0) {
                # Restart WinRM service
                .\psservice.exe \\$computer restart WinRM
                $result = winrm id -r:$computer 2> $null

                if ($LastExitCode -eq 0) {
                    Write-Host "WinRM successfully enabled on $computer!" -ForegroundColor Green
                }
                else {
                    exit 1
                }
            }
        }
    }
}

# Usage example with multiple computers:
$computers = "mycomputer123", "anothercomputer456", "thirdcomputer789"
Enable-WinRM -Computers $computers
