#!/bin/bash - 
#===============================================================================
#
#          FILE: rstrtnamcd.sh
# 
#         USAGE: ./rstrtnamcd.sh 
# 
#   DESCRIPTION: SSC restart script for namcd daemon
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
#       OPTIONS: */30 * * * * /root/bin/rstrtnamcd.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Jun 10 2015 09:18
#  LAST UPDATED: Mon Mar 12 2018 11:55
#       VERSION: 0.1.5
#     SCRIPT ID: 063
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=namcd-monitor                              # email sender
email=root                                       # email recipient(s)
log='/var/log/rstrtnamcd.log'                    # log name and location (if required)
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
  echo -e "$ts" "$host": "$@" >> "$log"
}

function restartlum() { 
  logit "namcd is dead or missing critical accounts, a restart is necessary on $host."
  logit "Restart of namcd has been issued by cron job on $host."
  /etc/init.d/namcd stop | tee -a $log
  /etc/init.d/nscd restart | tee -a $log
  /etc/init.d/namcd start | tee -a $log
  logit "Restart command issued."
}

function mail_body1() { 
echo -e "The restart of the namcd daemon has failed and namcd may not be running on $host. Please login as casadmin, and attempt a manual restart. Check the log (/var/log/novell-lum/namcd.log) for errors."
}

function lumAcheck() { 
  /etc/init.d/namcd status &>/dev/null
  namcdReturnCodeA=$?
  if [ $namcdReturnCodeA = 0 ]; then
    logit "namcd was successfully restarted on $host."
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n "$email" ]; then
      mail_body1 | mail -s "ATTENTION: namcd restart on $host failed, please investigate!" -r $mfrom $email
    fi
  fi
}

function lumrunning() { 
  logit "namcd is running fine on $host, no need to restart namcd daemon."
}

initlog

# Check to see if the VIP account is in the cache
CA1=$(/usr/bin/id tsmadm | awk '{ print $1 }')

# write the values to a file temporarily
echo "$CA1" > /tmp/ca1.tmp.$$

# If there are is no uid in the variable then LUM is not working
if [ -n "$(cat /tmp/ca1.tmp.$$ | cut -f 1 -d '=')" ]; then
  lumrunning
else
  logit "Critical accounts seem to be missing from LUM."
  restartlum
  lumAcheck
fi

# Clean up
rm -f /tmp/ca*.tmp.$$

# Finished
exit 0
