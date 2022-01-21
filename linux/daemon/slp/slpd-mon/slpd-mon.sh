#!/bin/bash - 
#===============================================================================
#
#          FILE: slpd-mon.sh
# 
#         USAGE: ./slpd-mon.sh 
# 
#   DESCRIPTION: Monitor and restart SLP daemon if it crashes
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
#       OPTIONS: */5 * * * * /root/bin/slpd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Feb 12 2013 12:53
#  LAST UPDATED: Mon Mar 12 2018 12:03
#       VERSION: 0.1.6
#     SCRIPT ID: 013
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=slpd-monitor                               # email sender
email=root                                       # email recipient(s)
log='/var/log/slpd-mon.log'                      # log name and location (if required)
#===============================================================================
function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch "$log"
    echo "Logging started at ${ts}" > "$log"
    echo "All actions are being performed by the user: ${user}" >> "$log"
    echo " " >> "$log"
  fi
}

function logit() { 
  echo "$ts" "$host": "$@" >> "$log"
}

initlog

# Check for the current status of the eDirectory daemon ndsd
 /usr/sbin/rcslpd status &>/dev/null
 slpdReturnCode=$?

logit "Return Code for SLPD: $slpdReturnCode"

function mail_body1() { 
echo -e "Service Location Protocol daemon is not running on server $host. An automatic restart is being attempted now."
}

function mail_body2() { 
echo -e "The restart of the slpd daemon failed, please investigate $host.\nLogon to the server and manually restart the service, and review /var/log/messages for the cause of the failure."
}

# Act if slpd is down
if [ $slpdReturnCode == "0" ]; then
	logit "SLPD service is running"
else
	if [ -n "$email" ]; then
		mail_body1 | mail -s "SLPD is DOWN" -r $mfrom $email
	fi
	logit "SLP is not running on the server, attempting a restart now"
	/usr/sbin/rcslpd restart
	logit "SLPD restart attempt complete"
	sleep 5
	/etc/init.d/slpd status &>/dev/null
	slpReturnCode2=$?
	if [ $slpReturnCode2 == "0" ]; then
		logit "Verified that slpd is now running"
	else
		mail_body2 | mail -s "SLPD Restart Failed" -r $mfrom $email
	fi 
fi

# Finished
exit 0
