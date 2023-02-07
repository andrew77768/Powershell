#Todo
#Merge it all into one big for loop so it does the whole script consecutively on each RDSH in turn which would balance out users reconnecting nicely.
#Uni parms
#Auto detect, Collections and their SH from CB (localhost) 

#Requires -RunAsAdministrator
Import-Module RemoteDesktop

#Requires -Modules RemoteDesktop
$ConnectionBroker = "testgwcb.ag.local"
$SessionHosts = ("TestRDS1.AG.local","TestRDS2.AG.local")

#Initiate connections to each RDSH defined above
foreach($SessionHost in $SessionHosts){

    Set-RDSessionHost -SessionHost $SessionHost -NewConnectionAllowed No -ConnectionBroker $ConnectionBroker
    $s = New-PSSession -computerName $SessionHost
    Invoke-Command -Session $s -Scriptblock {

    #Message all users on the hosts
    msg * "Server is shutting down in 90 seconds!"

    #Sleep
    Start-Sleep -Seconds 60

    #Initiate a graceful, 30 second notice shutdown
    shutdown -r -t 30

    # Get active sessions from broker
    $ActiveSessions = Get-RDUserSession -CollectionName "TestAGRDS" -ConnectionBroker $ConnectionBroker

    # Browse all open sessions and close sessions on the session host server configured in parameter
        foreach($Session in $ActiveSessions){

            #Write Event
            Write-EventLog -LogName "System" -Source "EventLog" -EventId 6013 -EntryType Information -Message "$Session.UserName Logged off by initiated reboot"

            # Write-Host $Session.UnifiedSessionID -ForegroundColor Red
            Invoke-RDUserLogoff -HostServer $SessionHost -UnifiedSessionID $Session.UnifiedSessionID -Force
        }
    }
}

#Set each host to be back in the pool and allowing connections every 180 seconds.
foreach($SessionHost in $SessionHosts){
    #Sleep to allow reboot to finish.
    Start-Sleep -Seconds 180
    #Allow remote connections to host.
    Set-RDSessionHost -SessionHost $SessionHost -NewConnectionAllowed Yes -ConnectionBroker $ConnectionBroker
}
