#!/bin/bash
#===============================================================================
#
#          FILE: inst_dynmotd.sh
# 
#         USAGE: ./inst_dynmotd.sh 
# 
#   DESCRIPTION: Install files for the dynamic message of the day script
#
#                Copyright (C) 2015  David Robb
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
#       OPTIONS: 
#  REQUIREMENTS: 
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Nov 27 2015 16:33
#  LAST UPDATED: Wed Jul 27 2016 09:38
#      REVISION: 2
#     SCRIPT ID: 099
#===============================================================================
set -o nounset                                    # Treat unset variables as an error
version=0.1.2                                     # version
sid=099                                           # script ID number
ts=$(date +"%b %d %T")                            # general date/time stamp
host=$(hostname)                                  # host name of local server
user=$(whoami)                                    # user checking routine
org='Excession Systems Research and Development Environment'    # Organization name
admin=david.robb@excession.org                    # e-mail address of designated administrator
dse=david.robb@microfocus.com                     # e-mail address of Dedicated support Engineer
log='/var/log/inst_dynmotd.log'                   # logging (if required)
src="/root/shared/scripts/dyn-motd/dev"           # source folder for files
lbin="/usr/local/bin"                             # location for dynmotd script
sshd="/etc/ssh"                                   # ssh configuration files
pl=$(cat /etc/SuSE-release | grep -w PATCHLEVEL | cut -f 2 -d "=" | sed 's/^ [\t]*//')     # Current OS support pack level

echo "The current server patch level is: $pl"
sleep 2

# Copy files to the correct locations
cp $src/.profile /root/.profile

users=$(ls /home | grep -v lost+found)
for u in $users
do
  cp $src/.profile /home/$u/
done

cp $src/dynmotd $lbin/
chmod +x $lbin/dynmotd
cp $src/issue /etc/

if [ $pl = 3 ]; then
  cp $src/os-release /etc/os-release
else
  echo "No need to copy os-release to SLES11 SP4, SLES12/SP1/SP2"
fi

cp $src/motd-* /etc/

if [ -f /etc/novell-release ]; then
  cp $src/sshd-banner-oes $sshd/sshd-banner
else
  cp $src/sshd-banner $ssh
fi

# Modify ssh daemon configuration
ssh1=$(cat /etc/ssh/sshd_config | grep -w LoginGraceTime | grep -v "#")
echo -e "$ssh1" > /tmp/ssh1.tmp.$$
if [ -z "$(cat /tmp/ssh1.tmp.$$)" ]; then
  echo "LoginGraceTime 2m" >> /etc/ssh/sshd_config
fi
ssh2=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")
echo -e "$ssh2" > /tmp/ssh2.tmp.$$
if [ -z "$(cat /tmp/ssh2.tmp.$$)" ]; then
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi
ssh3=$(cat /etc/ssh/sshd_config | grep -w MaxAuthTries | grep -v "#")
echo -e "$ssh3" > /tmp/ssh3.tmp.$$
if [ -z "$(cat /tmp/ssh3.tmp.$$)" ]; then
  echo "MaxAuthTries 6" >> /etc/ssh/sshd_config
fi
ssh4=$(cat /etc/ssh/sshd_config | grep -w MaxSessions | grep -v "#")
echo -e "$ssh4" > /tmp/ssh4.tmp.$$
if [ -z "$(cat /tmp/ssh4.tmp.$$)" ]; then
  echo "MaxSessions 10" >> /etc/ssh/sshd_config
fi
ssh5=$(cat /etc/ssh/sshd_config | grep -w ClientAliveInterval | grep -v "#")
echo -e "$ssh5" > /tmp/ssh5.tmp.$$
if [ -z "$(cat /tmp/ssh5.tmp.$$)" ]; then
  echo "ClientAliveInterval 1200" >> /etc/ssh/sshd_config
fi
ssh6=$(cat /etc/ssh/sshd_config | grep -w ClientAliveCountMax | grep -v "#")
echo -e "$ssh6" > /tmp/ssh6.tmp.$$
if [ -z "$(cat /tmp/ssh6.tmp.$$)" ]; then
  echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
fi
ssh7=$(cat /etc/ssh/sshd_config | grep -w Banner | grep -v "#")
echo -e "$ssh7" > /tmp/ssh7.tmp.$$
if [ -z "$(cat /tmp/ssh7.tmp.$$)" ]; then
  echo "Banner /etc/ssh/sshd-banner" >> /etc/ssh/sshd_config
fi

# Restart sshd
service sshd restart

exit 1

