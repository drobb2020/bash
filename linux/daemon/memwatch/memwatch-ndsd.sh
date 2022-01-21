#!/bin/bash - 
#===============================================================================
#
#          FILE: memwatch.sh
# 
#         USAGE: ./memwatch.sh 
# 
#   DESCRIPTION: Script to monitor high memory utilization
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
#       OPTIONS: * 1 * * * root /root/bin/memwatch-ndsd.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Dec 12 2012 09:00
#  LAST UPDATED: Wed Dec 13 2018 09:33
#       VERSION: 0.1.1
#     SCRIPT ID: 009
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=memory-watch                               # email sender
email=                                           # email recipient(s)
log='/var/log/memwatch.log'                      # log name and location (if required)
memlimit=80                                      # memory utilization limit
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

# Run top in batch mode - this should be run via cron on a regular basis

function ndsd_pid() { 
# Get the PID of ndsd
/sbin/pidof ndsd
pidofndsd=$?
}

ndsd_pid && /usr/bin/top -b -n1 -p $pidofndsd > /tmp/topmem.txt

PROC=ndsd
MEMF=$(sed -n '8p' /tmp/topmem.txt | awk '{print $10}')
MEM=$(sed -n '8p' /tmp/topmem.txt | awk '{print $10}' | cut -f 1 -d ".")

logit "The current memory consumption for $PROC is $MEMF% of total memory"

function mail_body() {
echo -e "The daemon $PROC is using $MEMF%, this is more memory than expected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the offending daemon, or;\n2) Restart the server."
}

function mail_body2() { 
echo -e "The restart of the ndsd daemon has failed and ndsd may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
}

function restart_daemon() { 
# if the daemon is ndsd and the memlimit has been exceeded then restart ndsd
if [ "$MEM" -ge $memlimit ] && [ "$PROC" == ndsd ]; then
  logit "eDirectory is consuming too much memory on $host, attempting restart now"
  /usr/sbin/rcndsd restart
  logit "NDSD restart attempt complete"
  sleep 15
  # Ensure NDSD is running
  /usr/sbin/rcndsd status &>/dev/null
  sleep 5
  ndsdReturnCode=$?
  if [ $ndsdReturnCode == 0 ]; then
    logit "Confirmed ndsd daemon successfully restarted."
  else
    logit "For some reason the restart of ndsd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n "$email" ]; then
      mail_body2 | mail -s "ATTENTION: ndsd restart on $host failed please investigate!" -r $mfrom "$email"
    fi
  fi
fi
}

if [ "$MEM" -ge $memlimit ]; then
  logit "Memory consumption is greater than $memlimit%, sending email to $email"
  mail_body | mail -s "High memory utilization on $host" -a /tmp/topmem.txt -r $mfrom "$email"
  logit "An e-mail alert has been sent to $email"
  restart_daemon
else
  logit "Memory consumption is normal at this time"
fi

# Cleanup tmp files
rm -f /tmp/topmem.txt

# Finished
exit 0
