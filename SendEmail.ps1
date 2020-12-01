#PS Script to trigger an email to send. Prev used to send email when an ANPR file had been moved to shared location. Uses O365

$username = "EMAIL-ADDRESS"
$password = "EMAIL-ADDRESS PASSWORD"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

$body1 = “
The ANPR Spreadsheet has been moved!
<br></br>
It is now located <a href='S:\IT\ANPR\'>here.</a>
<br></br>
Ready to import into the ANPR camera <a href='http://anpr'>here.</a>”

$body2 = " <br></br>Any issues please consult the SOP which is located <a href='S:\IT\ANPR\'>here.</a>"
$body3 = " <br></br>Any further issues please contact IT@me.com"

$body = $body1 + $body2 + $body3

Send-MailMessage -To EmailtoRecieve -from EmailOfCredsAbove -Subject 'ANPR Export' -Body $body -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $Creds -Port 587 
