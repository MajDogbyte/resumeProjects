Invoke-Command  hostname -ScriptBlock {$EdgeVersion = (Get-AppxPackage "Microsoft.MicrosoftEdge.Stable" -AllUsers).Version; 
if ($EdgeVersion.count -gt 1){$EdgeVersion = $EdgeVersion[-1]};
$EdgeSetupPath = ${env:ProgramFiles(x86)} + '\Microsoft\Edge\Application\' + $EdgeVersion + '\Installer\setup.exe';
& $EdgeSetupPath --uninstall --system-level --verbose-logging --force-uninstall} -Credential get-credential