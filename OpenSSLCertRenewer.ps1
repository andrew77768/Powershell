$ShortDate = Get-Date -Format "dd-MMM-yyyy"
$ShortTime = Get-Date -Format "HH-mm-ss"
Start-Transcript -Path "C:\Transcripts\$ShortDate-$ShortTime.txt" -NoClobber

$CWD = Get-Location

if (Test-Path $CWD\*.pfx)
{
    #OpenSSLCertificateRenewer
    #C:\Program Files\OpenSSL-Win64\bin
    
    Write-Host @"
    
    OpenSSL Certificate Renewer!
    Ensure you have the current .pfx file ready in the current directory!
    Ensure you have the new .cer, .p7b and .pem files ready in the current directory!
    
    Ensure you have the PATH environment variable set: "C:\Program Files\OpenSSL-Win64\bin"
"@

    #Encrypted path is going to be in our CWD & Encrypted to dump encrypted export
    $EncryptedPath = "$CWD\Encrypted"
            
    If(!(Test-Path $EncryptedPath))
    {
        New-Item -ItemType "Directory" -Path $EncryptedPath
        Write-Host "Created the $EncryptedPath environment."
    }

    $Password = "951753A!"

    $OldCertificate = Join-Path -Path $CWD *.pfx

    Write-Host "Current Working Directory: $CWD"

    #GetCN for certificate
    $CertCN = invoke-expression "openssl x509 -noout -subject -in *.pem"
    
    #Split on the = back from the common name
    $CertCNSplit = $CertCN -split '='
    $CNStripped = $CertCNSplit[2]
    Write-Host $CNStripped
    
    #Identify if it's a wildcard from the CN and replace asterix
    if ($CNStripped -match '\*') {
        Write-Host "Wildcard has been matched, previous CN: $CNStripped."
        $CNStripped = $CNStripped.Replace("*.","WILDCARD_")
        $CNStripped = $CNStripped.Replace(" ","")
        Write-Host "Wildcard has been ammended with a prefix of WILDCARD_, new CN: $CNStripped."
    }

    #Export path is going to be in our CWD & CN name to export the new certs
    $ExportPath = "$CWD\$CNStripped"

    If(!(Test-Path $ExportPath))
    {
        Write-Host "Export Path did not exist, created the export path of $ExportPath"
        New-Item -ItemType "Directory" -Path $ExportPath
    }
    
    #Current Working Directory & Domain
    $CWDDomain = Join-Path $CWD $CNStripped
    
    $RenewdCertificateCRT = Join-Path -Path $CWD *.crt
    $NewCompleteCert2016 = Join-Path $CWDDomain "$CNStripped-SVR2016Above_PCKS12.pfx"
    $NewCompleteCert2012 = Join-Path $CWDDomain "$CNStripped-SVR2012Below_PBESHA13DES.pfx"
    
    #Generate The Private Key Variable
    $PrivateKey = Join-Path $CWD "$CNStripped-PrivateKey.key"

    
    #Extract the private key from the old certificate
    invoke-expression "openssl pkcs12 -in '$OldCertificate' -nocerts -out '$PrivateKey' -passin pass:$Password -passout pass:$Password"
    
    Write-Host "Got private key: $PrivateKey"
    Write-Host ""
    Write-Host ""

    
    #Create a new certificate ($NewCompleteCert2016) in pkcs12 format using the private key ($PrivateKey) and the new CRT from the CA ($RenewdCertificateCRT)
    invoke-expression "openssl pkcs12 -export -out '$NewCompleteCert2016' -inkey '$PrivateKey' -in '$RenewdCertificateCRT' -passin pass:$Password -passout pass:$Password"
    
    Write-Host "Certificate $NewCompleteCert2016 has been created with the default set password!"
    Write-Host ""
    Write-Host ""
    
    
    #Create a new certificate ($NewCompleteCert2012) in PBE-SHA1-3DES format using the private key ($PrivateKey) and the new CRT from the CA ($RenewdCertificateCRT)
    invoke-expression "openssl pkcs12 -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -nomac -export -out '$NewCompleteCert2012' -inkey '$PrivateKey' -in '$RenewdCertificateCRT' -passin pass:$Password -passout pass:$Password"
    
    Write-Host "Certificate $NewCompleteCert2012 has been created with the default set password!"
    Write-Host ""
    Write-Host ""
    
    Start-Sleep -Seconds 5
    
    Compress-Archive -Path $CWDDomain -DestinationPath $EncryptedPath\$CNStripped.zip
    
    Start-Sleep -Seconds 5

    #Self cleanup, remove all of the old files in the CWD (new certificates are not in the CWD but a child folder)
    Remove-Item -Path $CWD\* -Include *.crt,*.key,*.pem,*.p7b,*.pfx

    Start-Sleep -Seconds 5

    #Spawning the POST request to MSFT Teams for the channel notifcation to alert the engineer it has been actioned.
    $JSON = [Ordered]@{
        "type"     = "message"
        "attachments" = @(
        @{
            "contentType" = 'application/vnd.microsoft.card.adaptive'
            "content"    = [Ordered]@{
            '$schema' = "<http://adaptivecards.io/schemas/adaptive-card.json>"
            "type"  = "AdaptiveCard"
            "version" = "1.0"
            "body"  = @(
                [Ordered]@{
                "type"  = "Container"
                "items" = @( ## The different contained elements such as TextBlock or an Image.
                    @{
                        "type"   = "Image"
                        "url" = "https://statics.teams.cdn.office.net/evergreen-assets/apps/teams_dev_app_largeimage.png"
                        "size" = "Large"
                        "wrap"   = $true
                    }   
                    @{
                        "type"   = "TextBlock"
                        "text"   = "The $CNStripped SSL Certificate has been created!"
                        "wrap"   = $true ## whether to wrap text that expands past the size of the card itself.
                        "weight" = "Bolder" ## Whether to show the card as bolder, lighter, or as the default. If omitted then the text will be shown as default.
                        "size"   = "Large" ## The size of the text ranging from small, default, medium, large, or extralarge. If omitted then the text will be shown as default.
                    }
                    @{
                        "type"   = "TextBlock"
                        "text"   = "It has been stored in \\\SERVER\SSLCerts\$CNStripped"
                        "wrap"   = $true
                    }
                )
                }
            )
            }
        }
        )
    } | ConvertTo-JSON -Depth 20

    Write-Host "Sending Teams notifcation for $CNStripped"
    $TeamsConnectorParams = @{
        "URI" = ""
        "Method" = 'POST'
        "Body" = $JSON
        "ContentType" = 'application/json'
    }

    Start-Sleep 5

    Invoke-RestMethod @TeamsConnectorParams
}
else 
{
    Write-Host "Exiting because Test-Path $CWD\*.pfx shows a PFX doesn't exist in the directory. No need to run"
    Exit
}
