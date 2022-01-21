#!/bin/bash - 
#===============================================================================
#
#          FILE: restartndsd.sh
# 
#         USAGE: ./restartndsd.sh 
# 
#   DESCRIPTION: Script to restart ndsd on a monthly schedule using cron
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
#       OPTIONS: Use common cron syntax to create restart schedule
#  REQUIREMENTS: Remember to stagger the restart time on servers within the same replica ring
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Jul 23 2014 07:36
#  LAST UPDATED: Mon Mar 12 2018 11:41
#       VERSION: 0.1.4
#     SCRIPT ID: 011
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=eDir-maintenance                           # email sender
email=root                                       # email recipient(s)
log='/var/log/restartndsd.log'                   # log name and location (if required)
#===============================================================================

function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch "$log"
    echo "Logging started at ${ts}";
    echo "All actions are being performed by the user: ${user}";
		echo "NDSD Monthly Restart log";
    echo " " >> "$log"
  fi
}

function logit() { 
  echo -e "$ts" "$host": "$@" >> "$log"
}

initlog

# Check current status of daemon
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode=$?
if [ $ndsdReturnCode = 0 ]
    then
        logit "Restart of ndsd issued by cron job on $host."
        /etc/init.d/ndsd restart | tee -a $log
	logit "Restart command issued."
fi

function mail_body1() { 
echo -e "The ndsd daemon has successfully restarted on $host as per the monthly cron schedule. Please review the $log for any additional details."
}

function mailbody2() { 
echo -e "The scheduled restart of the ndsd daemon has failed and ndsd may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
}

# Check new status of daemon (lets hope it's running)
sleep 5
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode2=$?
if [ $ndsdReturnCode2 = 0 ]
    then
        logit "ndsd daemon successfully restarted."
	if [ -n "$email" ]
	    then
		mail_body1 | mail -s "ndsd restarted on $host" -r $mfrom $email
	fi
    else
        logit "For some reason the last restart of ndsd failed."
        logit "The daemon may be dead at this time."
        logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
	if [ -n "$email" ] 
	    then
		mail_body2 | mail -s "ATTENTION: ndsd restart on $host failed, please investigate!" -r $mfrom $email
	fi
fi

# Finished
exit 0
