#!/bin/bash - 
#===============================================================================
#
#          FILE: httpstk-mon.sh
# 
#         USAGE: ./httpstk-mon.sh 
# 
#   DESCRIPTION: Script to monitor the httpstkd daemon and restart if necessary
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
#       OPTIONS: */5 * * * * root /root/bin/httpstk-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Dec 19 2012 08:47
#  LAST UPDATED: Mon Mar 12 2018 08:19
#       VERSION: 0.1.5
#     SCRIPT ID: 008
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
user=$(whoami)                                   # who is running the script
host=$(hostname -f)                              # hostname
log='/var/log/httpstk-mon.log'                   # log name and location (if required)
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
	echo "$ts" "$host": "$@" >> "$log"
}

initlog

# Check the current status of novel-httpstkd
if [ -e /var/run/httpstkd.pid ]; then
  PIDD=$(cat /var/run/httpstkd.pid)
  PS=$(pgrep httpstkd)
  if [ "$PIDD" -eq "$PS" ]; then
    logit "novell-httpstkd appears to be running correctly"
	else
    logit "PID file exists but the daemon is dead"
    rm -f /var/run/httpstkd.pid
    kill -9 "$PIDD"
    /etc/init.d/novell-httpstkd restart
    logit "novell-httpstkd daemon has been restarted"
  fi
else
  logit "httpstkd.pid does not exist, daemon is stopped, going to do a restart."
  /etc/init.d/novell-httpstkd start
fi

exit 0
