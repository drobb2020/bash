#!/bin/bash - 
#===============================================================================
#
#          FILE: load-mon.sh
# 
#         USAGE: ./load-mon.sh 
# 
#   DESCRIPTION: Monitor the ongoing load average on a server and alert when
#                server is showing an overload condition
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
#       CREATED: Tue Aug 09 2016 13:59
#  LAST UPDATED: Sun Mar 18 2018 10:59
#       VERSION: 0.1.2
#     SCRIPT ID: 073
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                     # general date|time stamp
host=$(hostname)                           # hostname of the local server
user=$(whoami)                             # who is running the script
mfrom=load-monitor                         # email sender
email=root                                 # email recipient(s)
log='/var/log/load-mon.log'                # log name and location (if required)
#===============================================================================

# Initialize logging
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

initlog

# How many processors does this server have?
nuprocs=$(grep -c processor /proc/cpuinfo)

logit "This server has $nuprocs processors."

# How much memory does this server have?
phymem=$(grep MemTotal /proc/meminfo | cut -f 2 -d ':' | sed -e 's/^ [ /t]*//')

logit "This server has $phymem of memory."

# What is the current load average?
cla=$(awk '{print $1, $2, $3}' /proc/loadavg)

logit "The current 1, 5, and 15 minute load average is: $cla"

# Let's divide the 1 minute load average by the number of processors to get the load percentage
ola=$(echo "$cla" | awk '{ print $NR }')
var=$(echo "scale=4; $ola / $nuprocs" | bc)
lp=$(echo "$var * 100" | bc)

logit "The current load percentage on this server is: $lp %"

lpi=$(echo "$lp" | cut -f 1 -d '.')

#mail message
function mail_body1() { 
echo -e "The load percentage for all processors on $host is exceeding the threshold of 75% . Please check the server immediately to see what is causing this load (use top)."
}

# email an alert if the processor load percentage is more than 75%
if [ "$lpi" -ge 75 ]; then
  if [ -n "$email" ]; then
	mail_body1 | mail -s "ATTENTION: load percentage on $host is above the threshold of 75%, please investigate!" -r "$mfrom" "$email"
  fi
fi

# Finished
exit 0
