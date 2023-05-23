$hashBytes = [System.Text.Encoding]::UTF8.GetBytes("baseball")
$sha1 = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
$hashedPassword = [System.BitConverter]::ToString($sha1.ComputeHash($hashBytes)).Replace('-', '')
$hashedPassword