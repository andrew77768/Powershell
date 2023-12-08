#OpenSSLCertificateRenewer
#C:\Program Files\OpenSSL-Win64\bin

Write-Host @"

OpenSSL Certificate Renewer!
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
$NewCompleteCert2016 = Join-Path $CWD "NewCert2016Above.pfx"
$NewCompleteCert2012 = Join-Path $CWD "NewCert2012Below.pfx"

Write-Host "Starting Command1"

invoke-expression "openssl pkcs12 -in '$OldCertificate' -nocerts -out '$PrivateKey' -passin pass:$Password -passout pass:$Password"

Write-Host "Command1 finished, got private key:$PrivateKey"
Write-Host ""
Write-Host ""

Write-Host "Starting Command2"

invoke-expression "openssl pkcs12 -export -out '$NewCompleteCert2016' -inkey '$PrivateKey' -in '$NewCertificate' -passin pass:$Password -passout pass:$Password"

Write-Host "Command2 finished, certificate $NewCompleteCert2016 has been created with the default set password!"
Write-Host ""
Write-Host ""

Write-Host "Starting Command3"

invoke-expression "openssl pkcs12 -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -nomac -export -out '$NewCompleteCert2012' -inkey '$PrivateKey' -in '$NewCertificate' -passin pass:$Password -passout pass:$Password"

Write-Host "Command3 finished, certificate $NewCompleteCert2012 has been created with the default set password!"
Write-Host ""
Write-Host ""

pause
