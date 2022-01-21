#!/bin/bash - 
#===============================================================================
#
#          FILE: connectionsnetstat.sh
# 
#         USAGE: ./connectionsnetstat.sh 
# 
#   DESCRIPTION: Script to count the number connections per IP Address on OES
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
#       CREATED: Wed May 27 2015 10:42
#  LAST UPDATED: Mon Mar 12 2018 08:03
#       VERSION: 0.1.4
#     SCRIPT ID: 005
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                     # general date|time stamp
host=$(hostname)                           # hostname of the local server
user=$(whoami)                             # who is running the script
log='/var/log/connectionsnetstat.log'      # log name and location (if required)
#===============================================================================
function initlog() { 
	if [ -e "$log" ]; then
        echo "log file exists" > /dev/null
	else
		touch "$log"
		echo "Logging started at ${ts}";
		echo "All actions are being performed by the user: ${user}";
		echo " " >> "$log"
	fi
}

function logit() { 
	echo "$ts" "$host" "$@" >> "$log"
}
initlog

echo "----Start Connection count per Address----";
echo "Number of Connection count per IP Address";
/bin/netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' | sort | uniq -c | sort -n | grep -v "and" | grep -v "Address";
echo "----END Connection count per Address----";
echo -e "\n";
echo "----Total Number of TCP/UDP Connections----";
/bin/netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' | grep -v "and" | grep -v "Address" | wc -l;
echo "----END Total Connection Count----" >> $log

exit 0
