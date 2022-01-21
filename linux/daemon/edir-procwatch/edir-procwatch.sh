#!/bin/bash - 
#===============================================================================
#
#          FILE: edir-procwatch.sh
# 
#         USAGE: ./edir-procwatch.sh 
# 
#   DESCRIPTION: Script to monitor and log the utilization of ndsd and ncp2nss
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
#       OPTIONS: */5 * * * * ~/bin/edir-procwatch.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Mar 12 2018 08:03
#  LAST UPDATED: Mon Mar 12 2018 08:06
#       VERSION: 0.1.4
#     SCRIPT ID: 006
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
user=$(whoami)                                   # who is running the script
host=$(hostname -f)                              # hostname
log='/var/log/edir-procwatch.log'                # log name and location (if required)
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

# get the pids of ndsd and ncp2nss
/bin/pidof ndsd >/tmp/ndsd.pid
/bin/pidof ncp2nss > /tmp/ncp2.pid
P1=$(awk '{print $1}' /tmp/ndsd.pid)
P2=$(awk '{print $1}' /tmp/ncp2.pid)

# Run top in batch mode and log the results for the two pids
/usr/bin/top -b -n1 -p"${P1}" -p"${P2}" > "$log"

exit 0
