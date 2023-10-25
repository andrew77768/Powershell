#OpenSSLCertificateRenewer
#C:\Program Files\OpenSSL-Win64\bin

Write-Host @"

OpenSSL Certificate Renewer!
Ensure you have the PATH environment variables set for your OpenSSL installation!
Ensure you have the current .pfx file ready in the current directory!
Ensure you have the new .cer file ready in the current directory!

"@

pause

$Password = "951753A!"

$CWD = Get-Location
$OldCertificate = Join-Path -Path $CWD *.pfx

Write-Host "Directory: $CWD"
$PrivateKey = Join-Path $CWD "PrivateKey.key"

$NewCertificate = Join-Path -Path $CWD *.crt
$NewCompleteCert = Join-Path $CWD "NewCert.pfx"

Write-Host "Starting Command1"

invoke-expression "openssl pkcs12 -in '$OldCertificate' -nocerts -out '$PrivateKey' -passin pass:$Password -passout pass:$Password"

Write-Host "Command1 finished, got private key:$PrivateKey"

Write-Host "Starting Command2"

invoke-expression "openssl pkcs12 -export -out '$NewCompleteCert' -inkey '$PrivateKey' -in '$NewCertificate' -passin pass:$Password -passout pass:$Password"

Write-Host "Command2 finished, certificate $NewCompleteCert has been created with the default set password!"
