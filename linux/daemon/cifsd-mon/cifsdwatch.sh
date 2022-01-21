#!/bin/bash - 
#===============================================================================
#
#          FILE: cifsdwatch.sh
# 
#         USAGE: ./cifsdwatch.sh 
# 
#   DESCRIPTION: Script to monitor high memory utilization on CIFS daemon
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
#       CREATED: Wed Jul 30 2014 09:52
#  LAST UPDATED: Mon Mar 12 2018 07:46
#       VERSION: 0.1.8
#     SCRIPT ID: 003
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
email=root                                       # email recipient(s)
log='/var/log/cifsdwatch.log'                    # log name and location (if required)
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

# Get the pids for cifsd
/bin/pidof cifsd > /tmp/cifsd.pid
P1=$(awk '{print $1}' /tmp/cifsd.pid)
P2=$(awk '{print $2}' /tmp/cifsd.pid)

# Lets find out how many concurrent connections there are
/usr/sbin/novcifs -C > /tmp/cifsdcc.tmp
CC=$(awk '{print $5}' /tmp/cifsdcc.tmp)
logit "There are currently $CC concurrent connections using cifs."

# Run top in batch mode - this should be run via cron on a regular basis
/usr/bin/top -b -n1 -p"$P1" -p"$P2" > /tmp/topcifsd.txt
PID1=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $1}')
PID2=$(sed -n '9p' /tmp/topcifsd.txt | awk '{print $1}')
PROC=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $12}')
MEMF1=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $10}')
MEM1=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $10}' | /usr/bin/cut -f 1 -d ".")
CPUF1=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $9}')
CPU1=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $9}' | /usr/bin/cut -f 1 -d ".")
MEMF2=$(sed -n '9p' /tmp/topcifsd.txt | awk '{print $10}')
MEM2=$(sed -n '9p' /tmp/topcifsd.txt | awk '{print $10}' | /usr/bin/cut -f 1 -d ".")
CPUF2=$(sed -n '9p' /tmp/topcifsd.txt | awk '{print $9}')
CPU2=$(sed -n '8p' /tmp/topcifsd.txt | awk '{print $9}' | /usr/bin/cut -f 1 -d ".")

logit "cifsd with PID $PID1 is currently consuming $MEMF1% of total memory"
logit "cifsd with PID $PID1 is currently consuming $CPUF1% of the CPU."
logit "cifsd with PID $PID2 is currently consuming $MEMF2% of total memory"
logit "cifsd with PID $PID2 is currently consuming $CPUF2% of the CPU."

function helpme() { 
	echo "The correct command line syntax is ./cifsdwatch.sh xx yy"
	echo "Where xx is the memory threshold, and yy is the cpu threshold."
	echo "for example ./cifsdwatch 20 40"
	exit 1
}

if [ $# -lt 2 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
	if [ "$MEM1" -ge "$1" ]; then
    logit "Memory consumption on cifsd PID $PID1 is greater than $1%, sending email to $email"
    echo -e "The $PROC daemon with pid $PID1 is using $MEMF1%, this is a greater memory consumption than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High memory consumption on $host by cifsd" -a /tmp/topcifsd.txt $email
    logit "An e-mail alert has been sent to $email"
  else
		logit "Memory consumption for cifsd (PID $PID1) is in the normal range at this time"
  fi
  if [ "$MEM2" -ge "$1" ]; then
    logit "Memory consumption on cifsd PID $PID2 is greater than $1%, sending email to $email"
    echo -e "The $PROC daemon with pid $PID2 is using $MEMF2%, this is a greater memory consumption than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High memory consumption on $host by cifsd" -a /tmp/topcifsd.txt $email
		logit "An e-mail alert has been sent to $email"
  else
		logit "Memory consumption for cifsd (PID $PID2) is in the normal range at this time"
  fi
  if [ "$CPU1" -ge "$2" ]; then
    logit "CPU consumption on cifsd PID $PID1 is greater than $2%, sending email to $email"
	  echo -e "The $PROC daemon with $PID1 is using $CPUF1%, this is a greater CPU utilization than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High CPU utilization on $host by cifsd" -a /tmp/topcifsd.txt $email
	  logit "An e-mail alert has been sent to $email"
  else
    logit "CPU utilization for cifsd (PID $PID1) is in the normal range at this time"
  fi
  if [ "$CPU2" -ge "$2" ]; then
    logit "CPU consumption on cifsd PID $PID2 is greater than $2%, sending email to $email"
    echo -e "The $PROC daemon with $PID2 is using $CPUF2%, this is a greater CPU utilization than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High CPU utilization on $host by cifsd" -a /tmp/topcifsd.txt $email
    logit "An e-mail alert has been sent to $email"
  else
    logit "CPU utilization for cifsd (PID $PID2) is in the normal range at this time"
  fi
fi

echo "----------------------------------------" >> "$LOG"

exit 0
