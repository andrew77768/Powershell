$exportFile = "C:\AADBitLockerKeys\CustomerName.htm"

Connect-MgGraph -Scopes BitLockerKey.Read.All -NoWelcome

$AzureADDevicesIDs = Get-MgInformationProtectionBitlockerRecoveryKey -All | select Id,CreatedDateTime,DeviceId,@{n="Key";e={(Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $_.Id -Property key).key}},VolumeType

$obj_report_Bitlocker = foreach ($device in $AzureADDevicesIDs){
    [pscustomobject]@{
        DisplayName = $Device."Id"
        CreatedDateTime = $Device."CreatedDateTime"
        keyID = $Device."DeviceId"
        recoveryKey = $Device."Key"
    }
}

$body = $null

$body += "<p><b>AzureAD Bitlocker key report</b></p>"
$body += @"
<table style=width:100% border="1">
<tr>
<th>Device</th>
</br>
<th>CreatedDateTime</th>
</br>
<th>KeyID</th>
</br>
<th>RecoveryKey</th>
</br>
</tr>
"@

$body += foreach ($Object in $obj_report_Bitlocker){
"<tr><td>" + $Object.DisplayName + " </td>"
"<td>" + $Object.CreatedDateTime + " </td>"
"<td>" + $Object.KeyID + " </td>"
"<td>" + $Object.RecoveryKey + "</td></tr>"
}
$body += "</table>"
$body > $exportFile

Disconnect-MgGraph
