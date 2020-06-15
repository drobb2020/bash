#!/bin/bash - 
#===============================================================================
#
#          FILE: load-mon.sh
# 
#         USAGE: ./load-mon.sh 
# 
#   DESCRIPTION: Monitor the ongoing load average on a server and alert when server
#                is showing an overload condition
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
#       CREATED: Tue Aug 09 2016 13:59
#  LAST UPDATED: Wed Aug 10 2016 09:39
#       VERSION: 1
#     SCRIPT ID: 073
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.1                                   # version number of the script
sid=073                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=calvin.hamilton@rcmp-grc.gc.ca,david.robb@rcmp-grc.gc.ca,root   # who to send email to (comma separated list)
log='/var/log/load-mon.log'                     # logging (if required)

function initlog() { 
  if [ -e $log ]; then
    #### ???
    echo "log file exists" > /dev/null
  else
    touch $.log
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function logit() { 
  echo -e $ts $host: $* >> ${log}
}

initlog
logit "---------------------------------------------------------------"

# How many processors does this server have?
nuprocs=$(grep -c processor /proc/cpuinfo)

logit "This server has $nuprocs processors."

# How much memory does this server have?
phymem=`cat /proc/meminfo | grep MemTotal | cut -f 2 -d ':' | sed -e 's/^ [ /t]*//'`

logit "This server has $phymem of memory."

# What is the current load average?
cla=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

logit "The current 1, 5, and 15 minute load average is: $cla"

# Let's divide the 1 minute load average by the number of processors to get the load percentage
ola=$(echo $cla | awk '{ print $NR }')
var=$(echo "scale=4; $ola / $nuprocs" | bc)
lp=$(echo "$var * 100" | bc)

logit "The current load percentage on this server is: $lp %"

lpi=$(echo $lp | cut -f 1 -d '.')

# email an alert if the processor load percentage is more than 75%
if [ $lpi -ge 75 ]; then
  if [ -n $email ]; then
	  echo -e "The load percentage for all processors on $host is exceeding the threshold of 75% . Please check the server immediately to see what is causing this load (use top)." | mail -s "ATTENTION: load percentage on $host is above 75%, please investigate!" $email
  fi
fi

exit 1

