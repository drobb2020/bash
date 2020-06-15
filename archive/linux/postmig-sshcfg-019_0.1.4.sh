#!/bin/bash - 
#===============================================================================
#
#          FILE: postmig-sshcfg.sh
# 
#         USAGE: ./postmig-sshcfg.sh 
# 
#   DESCRIPTION: Reset ssh configuration to RCMP/DSB defaults
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
#       CREATED: Tue May 27 2014 10:21
#  LAST UPDATED: Sun Jun 19 2016 12:01
#      REVISION: 3
#     SCRIPT ID: 019
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=019                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/postmig-sshcfg.log'               # logging (if required)
PRL0=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")

echo -e "$PRL0" > /tmp/prl0.tmp.$$
if [ -n "$(cat /tmp/prl0.tmp.$$)" ]; then
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  RESTARTSSH=true
else
  echo "The setting PermitRootLogin has already been set to NO, no further action taken."
fi

if  $RESTARTSSH ; then
  /etc/init.d/sshd restart
fi

# Clean up temporary files in /tmp
rm -f /tmp/*.tmp.$$

exit 1

