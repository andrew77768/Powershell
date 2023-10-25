# Powershell
PS Script Dump...

SendEmail.ps1:
This was created to send an email to a distribution group when a automated export task had completed exporting a spreadsheet of customer info and a batch file ((https://github.com/andrew77768/Batch/blob/master/ANPRMove.bat)) had moved this from a server to a share before triggering SendEmail.ps1. This was to prompt a user to move a spreadsheet of customer info into the LPR system, so it had an updated DB to use for triggering notifications.

Unfortunately, I never saved the full script on completion (importing into the LPR and merged everything to one file/lang(Py)) before I moved onto better things.

This won't be updated.



BTECRandomPWGenerator.ps1:
(Probably not going to be touched anymore.)

Matches majority of AD PW Policies:
Upper or lowercase letters (A through Z)
Numeric characters (0–9)
Non-alphanumeric characters like $, # or %
No more than two symbols from the user’s account name or display name



OpenSSLCertRenewer.ps1:
Rather than re-keying the certificate on renewal, the business choice was made to split the current/previous certificate for the private key and create a new certificate - this just makes the process slightly less tedious.

Put the .pfx file and .crt file in the same directory as the Powershell script, set the PATH environment variables to include your OpenSSL install if it hasn't been set already and run the script.
