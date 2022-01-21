#!/bin/bash - 
#===============================================================================
#
#          FILE: cifslogmon.sh
# 
#         USAGE: ./cifslogmon.sh 
# 
#   DESCRIPTION: Monitor the cifs.og for the occurrence of "Try again or restart CIFS"
#
#                Copyright (C) 2016  David Robb
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: Mon Sep 19 2016 08:22
#  LAST UPDATED: Mon Sep 19 2016 08:22
#       VERSION: 0.1.0
#     SCRIPT ID: 074
# SSC UNIQUE ID: --
#===============================================================================
ts=$(date +"%b %d %T")                          # general date/time stamp
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
log='/var/log/cifslogmon.log'                   # logging (if required)

function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
	else
		echo "Logging started at ${ts}" > "$log"
		echo "All actions are being performed by the user: ${user}" >> "$log"
		echo " " >> "$log"
  fi
}

function logit() { 
	echo "$ts" "$host" "$@" >> "$log"
}
# initlog

# Use /var/log/cifs/cifs.log as the monitoring source
lm='/var/log/cifs/cifs.log'
m1='Failed to duplicate context for DFS GET REFERRAL'
m2='CIFS server name not found in eDir'

grep -E "$lm" "$m1"|"$m2"
/usr/bin/tail -Fn0 $lm | \
	while read -r line ; do
		echo "$line" | grep -E 'm1|m2'
		if [ "$?" = 0 ]
		then
			echo "The CIFS error is present"
		fi
	done

exit 0
