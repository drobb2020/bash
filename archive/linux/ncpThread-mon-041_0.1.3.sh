#!/bin/bash - 
#===============================================================================
#
#          FILE: ncpThread-mon.sh
# 
#         USAGE: ./ncpThread-mon.sh 
# 
#   DESCRIPTION: Script to monitor the ncp thread and queue conditions on OES11
#
#                Copyright (C) 2015  David Robb
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: */15 * * * * /root/bin/ncpThread-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Feb 27 2014 13:45
#  LAST UPDATED: Tue Jul 21 2015 10:56
#      REVISION: 3
#     SCRIPT ID: 041
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=041                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/ncpThread-mon.log'            # logging (if required)
ds=$(date +%a)                              # Abreviated day of the week
df=$(date +%A)                              # Full day of the week
ncpbin=/sbin                                # Path to NCP binaries
threads=/tmp/threads.$$.tmp                 # Temporary holding file

function initlog() { 
if [ -e $log ]; then
  echo "log file exists" > /dev/null
else
  echo "Logging started on ${ts}" > ${log}
  echo "All actions are being performed by the user: ${user}" >> ${log}
  echo " " >> ${log}
fi
}

function logit() { 
	echo $ts $host $* >> ${log}
}

initlog

# Capture current thread information
/sbin/ncpcon threads 2>/dev/null 1>$threads

echo $ts >> $log

sleep 2
# Log some of the basic values
cat $threads | grep "Max Thread Size" >> $log
cat $threads | grep "Max Number of Additional SSG Threads" >> $log
cat $threads | grep "Number of Running Threads" >> $log
cat $threads | grep "Number of Queued Requests" >> $log

# Set the variables
rthread=$(cat $threads | grep "Number of Running Threads" | awk '{print $6}')
qrequests=$(cat $threads | grep "Number of Queued Requests" | awk '{print $6}')

# Test the variables
if [ "$(cat $threads | grep "Number of Running Threads" | awk '{print $6}')" -gt 64 ]; then
  echo -e "$ts $host - The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary." | mail -s "High NCP thread usage on $host" $EMAIL
  logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary."
else
  logit "Current NCP async thread count is: $rthread, there is no additional action required at this time."
fi

if [ "$(cat $threads | grep "Number of Queued Requests" | awk '{print $6}')" -gt 10000 ]; then
  echo -e "$ts $host - The current number of queued NCP requests is above the threshold of 10000. The request count is: $QREQUEST. Please investigate the server and restart the eDirectory daemon if necessary." | mail -s "High NCP Queued Requests on $host" $EMAIL
  logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary."
else
  logit "Current NCP queued requests are: $qrequests, there is no additional action required at this time."
fi

echo "-----------------------------------------------------------------------------------" >> $log

# Delete temporary file
rm -f $threads

exit 1

