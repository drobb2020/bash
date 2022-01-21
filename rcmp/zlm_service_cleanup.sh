#!/bin/sh
 #zlm_services_cleanup.sh
 #This script will attempt to cleanup any Services related files that cause the following error message.
 #ERROR: A service of type 'ZENworks' already exists on this client
 #Once cleaned up you will need to add your service again with rug. See the comment section at the bottom of the script.

/etc/init.d/novell-zmd stop

function check_pid_file()
 {
 test -f /var/run/zmd.pid
 }

if check_pid_file == 0; then
 echo -e "Killing ZENworks Management Daemon. \n"
 kill -9 `cat /var/run/zmd.pid`
 fi

echo -e "Removing all Services related files. \n"

rm /etc/opt/novell/zenworks/zmd/secret
 rm /etc/opt/novell/zenworks/zmd/deviceid
 rm /etc/opt/novell/zenworks/zmd/initial-service

rm -rf /var/opt/novell/zenworks/cache/zmd/web/files/*
 rm -rf /var/opt/novell/zenworks/cache/zmd/web/info/*
 rm -rf /var/opt/novell/zenworks/cache/zmd/web/packages/*

rm /var/opt/novell/zenworks/lib/zmd/services
 rm /var/opt/novell/zenworks/lib/zmd/subscriptions.xml
 rm /var/opt/novell/zenworks/lib/zmd/subscriptions

/etc/init.d/novell-zmd start

#Here is where we can add in our service add functionality to the script. 
 #Uncomment the lines below and change the rug sa command to fit your environment.
 #Note: the Sleep is needed to ensure that the zmd daemon is fully started.
 #sleep 5
 #/opt/novell/zenworks/bin/rug sa -k some-regkey https://zlm-server-hostname
