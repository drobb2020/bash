#!/bin/bash
REL=0.1-2
SID=029
##############################################################################
#
#    thread-mon.sh - script to monitor the ncp thread and queue condition.
#    Copyright (C) 2014  David Robb
#
##############################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
# Date Created: Thu 27 Feb 2014 13:45:55 EST 
# Last updated: Wed May 27 13:42:37 2015 
# Crontab command: */15 * * * * /root/bin/thread-mon.sh
# Supporting file: None
# Additional notes: 
##############################################################################
# Declare variables
DS=$(date +%a)
DF=$(date +%A)
TS=$(date +'%b %d %T')
HOST=$(hostname)
NCPSBIN=/sbin
EMAIL=root
THREADS=/tmp/threads.txt
LOG=/var/log/thread-mon.log

function initlog() { 
   if [ -e /var/log/thread-mon.log ]
	then
		echo "log file exists" > /dev/null
	else
		echo "Logging started on ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo $TS $HOST $* >> ${LOG}
}

initlog

# Capture current thread information
/sbin/ncpcon threads 2>/dev/null 1>$THREADS

echo $TS >> $LOG

sleep 2
# Log some of the basic values
cat $THREADS | grep "Max Thread Size" >> $LOG
cat $THREADS | grep "Max Number of Additional SSG Threads" >> $LOG
cat $THREADS | grep "Number of Running Threads" >> $LOG
cat $THREADS | grep "Number of Queued Requests" >> $LOG

# Set the variables
RTHREAD=$(cat $THREADS | grep "Number of Running Threads" | awk '{print $6}')
QREQUESTS=$(cat $THREADS | grep "Number of Queued Requests" | awk '{print $6}')

# Test the variables
if [ "$(cat $THREADS | grep "Number of Running Threads" | awk '{print $6}')" -gt 64 ]
    then
	echo -e "$TS $HOST - The current number of running NCP async threads is above the threshold of 64. The thread count is: $RTHREAD. Please investigate the server and restart the eDirectory daemon if necessary." | mail -s "High NCP thread usage on $HOST" $EMAIL
	logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $RTHREAD. Please investigate the server and restart the eDirectory daemon if necessary."
    else
	logit "Current NCP async thread count is: $RTHREAD, there is no additional action required at this time."
fi

if [ "$(cat $THREADS | grep "Number of Queued Requests" | awk '{print $6}')" -gt 10000 ]
    then
	echo -e "$TS $HOST - The current number of queued NCP requests is above the threshold of 10000. The request count is: $QREQUEST. Please investigate the server and restart the eDirectory daemon if necessary." | mail -s "High NCP Queued Requests on $HOST" $EMAIL
	logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $RTHREAD. Please investigate the server and restart the eDirectory daemon if necessary."
    else
	logit "Current NCP queued requests are: $QREQUESTS, there is no additional action required at this time."
fi
echo "-----------------------------------------------------------------------------------" >> $LOG

# Delete temporary file
rm -f $THREADS

exit 1

