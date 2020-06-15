#!/bin/bash - 
#===============================================================================
#
#          FILE: thread-mon.sh
# 
#         USAGE: ./thread-mon.sh 
# 
#   DESCRIPTION: Script to monitor the ndsd and ncp thread and queue conditions on OES11
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
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Feb 27 2014 13:45
#  LAST UPDATED: Sun Jun 19 2016 14:12
#      REVISION: 4
#     SCRIPT ID: 041
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.5
sid=041                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/thread-mon.log'               # logging (if required)
ds=$(date +%a)                              # abreviated day of the week
df=$(date +%A)                              # full day of the week
sd=$(date +'%a %b %d %Y %T')                # special date-time stamp
ncpsbin=/opt/novell/ncpserv/sbin            # path to NCP binaries
ndsdbin=/opt/novell/eDirectory/bin          # path to ndsd binaries
ncpthreads=/tmp/ncpthreads.$$.tmp           # temporary holding file ncp threads
ndsthreads=/tmp/ndsthreads.$$.tmp           # temporary holding file running nds threads
ndsmaxthreads=/tmp/ndsmaxthreads.$$.tmp     # temporary holding file for max nds threads

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
$ncpsbin/ncpcon threads 2>/dev/null 1>$ncpthreads
$ndsdbin/ndstrace -c threads 2>/dev/null 1>$ndsthreads
$ndsdbin/ndsconfig get n4u.server.max-threads 2>/dev/null 1>/$ndsmaxthreads

echo $sd >> $log

# Log some of the basic ncp values
echo -e "NCP thread details" >> $log
echo -e "---------------------------------------------------" >> $log
cat $ncpthreads | grep "Max Thread Size" >> $log
cat $ncpthreads | grep "Max Number of Additional SSG Threads" >> $log
cat $ncpthreads | grep "Number of Running Threads" >> $log
cat $ncpthreads | grep "Number of Queued Requests" >> $log
echo -e "" >> $log

# log some of the basic ndsd values
echo -e "NDSD thread details" >> $log
echo -e "---------------------------------------------------" >> $log
cat $ndsmaxthreads | grep "n4u" | cut -f 3 -d "." >> $log
cat $ndsthreads | grep "Summary" >> $log
cat $ndsthreads | grep "Pool Workers" >> $log
cat $ndsthreads | grep "Ready Work" >> $log
echo -e "" >> $log

# Set the ncp thread variables
rthread=$(cat $ncpthreads | grep "Number of Running Threads" | awk '{print $6}')
qrequests=$(cat $ncpthreads | grep "Number of Queued Requests" | awk '{print $6}')

# Test the ncp thread variables
if [ "$(cat $ncpthreads | grep "Number of Running Threads" | awk '{print $6}')" -gt 64 ]; then
  echo -e "$ts $host - The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary." | mail -s "High NCP thread usage on $host" $email
  logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary."
else
  logit "Current NCP async thread count is: $rthread, there is no additional action required at this time."
fi

if [ "$(cat $ncpthreads | grep "Number of Queued Requests" | awk '{print $6}')" -gt 10000 ]; then
  echo -e "$ts $host - The current number of queued NCP requests is above the threshold of 10000. The request count is: $qrequests. Please investigate the server and restart the eDirectory daemon if necessary." | mail -s "High NCP Queued Requests on $host" $email
  logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary."
else
  logit "Current NCP queued requests are: $qrequests, there is no additional action required at this time."
fi

# Set the ndsd thread variables
ithread=$(cat $ndsthreads | grep "Idle" | awk '{print $5}' | sed -e 's/,$//')
tthread=$(cat $ndsthreads | grep "Total" | awk '{print $7}' | sed -e 's/,$//')
mthread=$(cat $ndsmaxthreads | grep n4u | awk -F "=" '{print $2}')

# Test the ndsd thread variables
if [ "$(cat $ndsthreads | grep Idle | awk '{print $5}' | sed -e 's/,$//')" -le 0 ]; then
  echo -e "$ts $host - NDSD has exhuasted all idle threads at this time. This means that ready work for ndsd may be waiting for threads to become available. In turn this can cause increased CPU utilization on the server. Please investigate the server more closely. You may have to increase the max-thread settings via ndsconfig to resolve this issue. A restart of ndsd may also be required." | mail -s "NDSD Idle thread exhaustion on $host" $email
  logit "NDSD Idle threads are at 0. You may need to increase the value of n4u.server.max-threads via ndsconfig to resolve this situation."
else
 logit "NDSD Idle thread count is normal at this time; the number of idle threads is: $ithread, there is no additional action required at this time."
fi

if [ $tthread = $mthread ]; then
  echo -e "$ts $host - The Total allocated NDSD threads has hit the max-thread number. This means that the server cannot spawn any more threads at this time. Pleaes investigate the server more closely. You may have to increase the n4u.server.max-threads value to a higher number. The default is 256, and can be set as hight as 512." | mail -s "NDSD Total threads is equal to max-threads on $host" $email
  logit "NDSD Total threads are equal to the n4u.server.max-threads setting. This means NDSD cannot spawn new threads. You may need to increase the value of n4u.server.max-threads using ndsconfig set to resolve this issue."
else
  logit "NDSD Total threads are below the number max-threads at this time, there is no additional action required at this time."
fi

echo "------------------------------------------------------" >> $log

# Delete temporary file
rm -f $ncpthreads
rm -f $ndsthreads
rm -f $ndsmaxthreads

exit 1

