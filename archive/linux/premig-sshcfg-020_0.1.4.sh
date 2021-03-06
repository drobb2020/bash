#!/bin/bash - 
#===============================================================================
#
#          FILE: premig-sshcfg.sh
# 
#         USAGE: ./premig-sshcfg.sh 
# 
#   DESCRIPTION: ssh reconfiguration to allow root access to servers
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
#         NOTES: Once finished with root access be sure to run postmig-sshcfg.sh
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue May 27 2014 10:21
#  LAST UPDATED: Sun Jun 19 2016 12:01
#      REVISION: 3
#     SCRIPT ID: 020
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=020                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/premig-sshcfg.log'                # logging (if required)

# SSH Configuration
echo "--[ Notice ]----------------------------------"
echo "Updating SSH configuration"
echo "Going to temporarily allow root login via ssh."
echo "=============================================="
sleep 2

# Make a backup copy of the current sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Permit root to log in via ssh temporarily
PRL0=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")
echo -e "$PRL0" > /tmp/prl0.$$.tmp
if [ -n "$(cat /tmp/prl0.$$.tmp)" ]; then
  sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
  RESTARTSSH=true
else
 echo "The setting PermitRootLogin has already been set to Yes, no further action taken."
fi

# Make sure the local client port is set to 3479
P1=$(cat /etc/ssh/ssh_config | grep -w Port | grep -v "#")
echo -e "$P1" > /tmp/p1.$$.tmp
if [ -z "$(cat /tmp/p1.$$.tmp)" ]; then
  echo "Port 3479" >> /etc/ssh/ssh_config
else
  echo "The ssh client port setting has already been made, no further action taken."
fi

# Restart ssh daemon if changes were made
if  $RESTARTSSH ; then
  /etc/init.d/sshd restart
fi

# Clean up temporary files in /tmp
rm -f /tmp/*.$$.tmp

exit 1

