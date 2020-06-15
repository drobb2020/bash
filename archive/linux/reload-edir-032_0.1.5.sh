#!/bin/bash - 
#===============================================================================
#
#          FILE: reload-edir.sh
# 
#         USAGE: ./reload-edir.sh 
# 
#   DESCRIPTION: Restart eDirectory daemon without notifying users
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
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Mar 22 2011 11:53
#  LAST UPDATED: Sun Jun 19 2016 13:25
#      REVISION: 4
#     SCRIPT ID: 032
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.5
sid=032                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/reload-edir.log'                  # logging (if required)
maxcon=`ncpcon connections 2>/dev/null | sed -ne  "s/.*Connection Slots Allocated\t//pg"`

# Help screen to remind user of commandline syntax
function helpme() { 
  echo "--[ HELP ]------------------------"
  echo "The correct commandline syntax is:"
  echo "./reload-edir.sh disable"
  echo "=================================="
  exit 1
}

if [ "$#" -lt 1 ]; then
  echo -e "There are not enough arguments on the command line." > /dev/stderr
  helpme
fi

count=0
if [ "$1" == "disable" ]; then
  disable=`/sbin/ncpcon disable login 2>/dev/null`
  if echo -e $disable | grep "Login is now disabled" 1>/dev/null 2>&1; then
    echo -e $disable
    echo -e "Don't forget to 'ncpcon enable login' if you don't restart the server"
  else
    echo -e "'ncpcon disable login' is not supported... Hurry up and bounce the server..."
  fi
fi

echo Max Connections = $maxcon

# Lets clear everyone off the server
while [ $count -le $maxcon ]
do
  /sbin/ncpcon connection clear $count 1>/dev/null 2>&1
  count=`expr $count + 1`
done

echo "All connections are cleared. Safe to restart eDirectory"

/etc/init.d/ndsd restart

# Check new status of daemon (lets hope it's running)
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode2=$?
if [ $ndsdReturnCode2 == 0 ]; then
  echo -e "ndsd daemon successfully reloaded, but ncp logins are still disabled."
fi

# Do what the user selects (reboot or enable logins)
while true
  do
    read -p "Do you want to reboot the server (y/n): " YN
    echo "==========================================="
    case $YN in
    [Yy]* ) echo -e "Server will be rebooted immediately."; init 6;;
    [Nn]* ) /sbin/ncpcon enable login; echo -e "NCP Logins have been re-enabled."; break;;
    * ) echo "Please answer yes (y) or no (n).";;
    esac
  done

exit 1

