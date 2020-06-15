#!/bin/bash - 
#===============================================================================
#
#          FILE: premig-sshcfg.sh
# 
#         USAGE: ./premig-sshcfg.sh 
# 
#   DESCRIPTION: ssh reconfiguration to allow root access to servers (not RCMP/DSB default)
#
#                Copyright (c) 2018, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue May 27 2014 10:21
#   LAST UDATED: Tue Mar 13 2018 08:11
#       VERSION: 0.1.5
#     SCRIPT ID: 020
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.5                                    # version number of the script
sid=020                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=ssh-modification                           # email sender
email=root                                       # email recipient(s)
log='/var/log/premig-sshcfg.log'                 # log name and location (if required)
#===============================================================================

# SSH Configuration
echo "--[ Notice ]----------------------------------"
echo "Updating SSH configuration"
echo "Going to temporarily allow root login via ssh."
echo "=============================================="
sleep 2

# Make a backup copy of the current sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Permit root to log in via ssh temporarily
prl0=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")
echo -e "$prl0" > /tmp/prl0.$$.tmp
if [ -n "$(cat /tmp/prl0.$$.tmp)" ]; then
  sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
  restartSSH=true
else
 echo "The setting PermitRootLogin has already been set to Yes, no further action taken."
fi

# Make sure the local client port is set to 3479
p1=$(cat /etc/ssh/ssh_config | grep -w Port | grep -v "#")
echo -e "$p1" > /tmp/p1.$$.tmp
if [ -z "$(cat /tmp/p1.$$.tmp)" ]; then
  echo "Port 3479" >> /etc/ssh/ssh_config
else
  echo "The ssh client port setting has already been made, no further action taken."
fi

# Restart ssh daemon if changes were made
if  $restartSSH ; then
  /etc/init.d/sshd restart
fi

# Clean up temporary files in /tmp
rm -f /tmp/*.$$.tmp

# Finished
exit 1

