#!/bin/bash - 
#===============================================================================
#
#          FILE: zlm_service_cleanup.sh
# 
#         USAGE: ./zlm_service_cleanup.sh 
# 
#   DESCRIPTION: This script will attempt to cleanup any Services related files that cause the following error message.
#                ERROR: A service of type 'ZENworks' already exists on this client
#
#                Copyright (C) 2016  David Robb
#
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: Once cleaned up you will need to add your service again with rug. 
#                See the comment section at the bottom of the script.
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Sun Jun 19 2016 12:02
#  LAST UPDATED: Sun Jun 19 2016 12:08
#      REVISION: 1
#     SCRIPT ID: 017
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.2
sid=017                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/zlm_service_cleanup.log'          # logging (if required)

/etc/init.d/novell-zmd stop

function check_pid_file() {
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
sleep 5
#/opt/novell/zenworks/bin/rug sa -k some-regkey https://zlm-server-hostname

exit 1

