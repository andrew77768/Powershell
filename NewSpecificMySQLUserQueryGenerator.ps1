$NewSQLUser = Read-Host "Please type the username for the user including a dot between the firstname and surname. E.G John.Doe"

$CWD = Get-Location

$NewSQLUserSplit = $NewSQLUser -split "\."
$NewSQLUserFirstName = $NewSQLUserSplit[0]
$NewSQLUserSurname = $NewSQLUserSplit[1]

$NewSQLUserSpace = $NewSQLUser.replace("."," ")

$SQLCommands = @("
CREATE USER '$NewSQLUser'@'192.168.%.%';
GRANT Delete ON Contacts.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Insert ON Contacts.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Select ON Contacts.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Update ON Contacts.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Update ON DB1.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Select ON DB1.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Insert ON DB1.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Delete ON DB1.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Update ON DB2.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Select ON DB2.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Insert ON DB2.* TO '$NewSQLUser'@'192.168.%.%';
GRANT Delete ON DB2.* TO '$NewSQLUser'@'192.168.%.%';
INSERT INTO DB1.Permission (Username,Permission,RealName) VALUES ('$NewSQLUser',3,'$NewSQLUserSpace');

INSERT INTO DB2.Logon (Username,Password,Fullname,Level) VALUES ('$NewSQLUser','$NewSQLUserSurname','$NewSQLUserSpace',3);

FLUSH PRIVILEGES;
"
)

$SQLCommands | Out-File -FilePath $CWD\DBMySQLUser-$NewSQLUser.sql

Write-Host "Username should be the full name entered: $NewSQLUser"
Write-Host "Password should be the surname: $NewSQLUserSurname"

Write-Host "SQL Query File is located: $CWD\DBMySQLUser-$NewSQLUser.sql"

pause
