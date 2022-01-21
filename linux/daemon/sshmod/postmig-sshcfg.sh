#!/bin/bash - 
#===============================================================================
#
#          FILE: postmig-sshcfg.sh
# 
#         USAGE: ./postmig-sshcfg.sh 
# 
#   DESCRIPTION: Disable ssh configuration to disallow root logins (RCMP/DSB defaults)
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
#  LAST UPDATED: Tue Mar 13 2018 08:05
#       VERSION: 0.1.5
#     SCRIPT ID: 019
# SSC SCRIPT ID: 00
#===============================================================================
prl0=$(grep -w PermitRootLogin /etc/ssh/sshd_config | grep -v "#") # current setting of PermitRootLogin
#===============================================================================
# Allow root login via ssh temporarily
echo -e "$prl0" > /tmp/prl0.tmp.$$
if [ -n "$(cat /tmp/prl0.tmp.$$)" ]; then
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  RESTARTSSH=true
else
  echo "The setting PermitRootLogin has already been set to NO, no further action taken."
fi

if  $RESTARTSSH ; then
  /etc/init.d/sshd restart
fi

# Clean up temporary files
rm -f /tmp/*.tmp.$$

# Finished
exit 0
