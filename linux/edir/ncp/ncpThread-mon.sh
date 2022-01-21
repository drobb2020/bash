#!/bin/bash - 
#===============================================================================
#
#          FILE: ncpThread-mon.sh
# 
#         USAGE: ./ncpThread-mon.sh 
# 
#   DESCRIPTION: Script to monitor the ndsd and ncp thread and queue conditions on OES
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
#       OPTIONS: */15 * * * * /root/bin/ncpThread-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Thu Feb 27 2014 13:45
#  LAST UPDATED: Thu Mar 15 2018 08:08
#       VERSION: 0.1.6
#     SCRIPT ID: 041
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
sd=$(date +'%a %b %d %Y %T')                     # special date-time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=ncp-thread-monitor                         # email sender
email=root                                       # email recipient(s)
log='/var/log/ncpThread-mon.log'                 # log name and location (if required)
ncpsbin=/opt/novell/ncpserv/sbin                 # path to NCP binaries
ndsdbin=/opt/novell/eDirectory/bin               # path to ndsd binaries
ncpthreads=/tmp/ncpthreads.$$.tmp                # temporary holding file ncp threads
ndsthreads=/tmp/ndsthreads.$$.tmp                # temporary holding file running nds threads
ndsmaxthreads=/tmp/ndsmaxthreads.$$.tmp          # temporary holding file for max nds threads
#===============================================================================

# initialize logging
function initlog() { 
if [ -e "$log" ]; then
  echo "log file exists" > /dev/null
else
  echo "Logging started on ${ts}" > "$log"
  echo "All actions are being performed by the user: ${user}" >> "$log"
  echo " " >> "$log"
fi
}

function logit() { 
	echo "$ts" "$host" "$@" >> "$log"
}

initlog

# Capture current thread information
$ncpsbin/ncpcon threads 2>/dev/null 1>$ncpthreads
$ndsdbin/ndstrace -c threads 2>/dev/null 1>$ndsthreads
$ndsdbin/ndsconfig get n4u.server.max-threads 2>/dev/null 1>/$ndsmaxthreads

echo "$sd" >> "$log"

# Log some of the basic ncp values
echo -e "NCP thread details";
echo -e "---------------------------------------------------";
cat $ncpthreads | grep "Max Thread Size";
cat $ncpthreads | grep "Max Number of Additional SSG Threads";
cat $ncpthreads | grep "Number of Running Threads";
cat $ncpthreads | grep "Number of Queued Requests";
echo -e "";

# log some of the basic ndsd values
echo -e "NDSD thread details";
echo -e "---------------------------------------------------";
cat $ndsmaxthreads | grep "n4u" | cut -f 3 -d ".";
cat $ndsthreads | grep "Summary";
cat $ndsthreads | grep "Pool Workers";
cat $ndsthreads | grep "Ready Work";
echo -e "" >> $log

# Set the ncp thread variables
rthread=$(cat $ncpthreads | grep "Number of Running Threads" | awk '{print $6}')
qrequests=$(cat $ncpthreads | grep "Number of Queued Requests" | awk '{print $6}')

# mail messages
function mail_body1() { 
echo -e "$ts $host - The current number of running NCP async threads is above the threshold of 64. The thread count is $rthread. Please investigate the server and restart the eDirectory daemon if necessary."
}

function mail_body2() { 
echo -e "$ts $host - The current number of queued NCP requests is above the threshold of 10000. The queued request count is $qrequests. Please investigate the server and restart the eDirectory daemon if necessary."
}

function mail_body3() { 
echo -e "$ts $host - NDSD has exhausted all idle threads at this time. This means that ready work for ndsd may be waiting for threads to become available. In turn this can cause increased CPU utilization on the server. Please investigate the server more closely. You may have to increase the max-thread settings via ndsconfig to resolve this issue. A restart of ndsd may also be required."
}

function mail_body4() { 
echo -e "$ts $host - The Total allocated NDSD threads has hit the max-thread number. This means that the server cannot spawn any more threads at this time. Please investigate the server more closely. You may have to increase the n4u.server.max-threads value to a higher number. The default is 256, and can be set as hight as 512."
}

# Test the ncp thread variables
if [ "$(cat $ncpthreads | grep "Number of Running Threads" | awk '{print $6}')" -gt 64 ]; then
  mail_body1 | mail -s "High NCP thread usage on $host" -r $mfrom $email
  logit "The current number of running NCP async threads is above the threshold of 64. The thread count is: $rthread. Please investigate the server and restart the eDirectory daemon if necessary."
else
  logit "Current NCP async thread count is: $rthread, there is no additional action required at this time."
fi

if [ "$(cat $ncpthreads | grep "Number of Queued Requests" | awk '{print $6}')" -gt 10000 ]; then
  mail_body2 | mail -s "High NCP Queued Requests on $host" -r $mfrom $email
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
  mail_body3 | mail -s "NDSD Idle thread exhaustion on $host" -r $mfrom $email
  logit "NDSD Idle threads are at 0. You may need to increase the value of n4u.server.max-threads via ndsconfig to resolve this situation."
else
  logit "NDSD Idle thread count is normal at this time; the number of idle threads is: $ithread, there is no additional action required at this time."
fi

if [ "$tthread" = "$mthread" ]; then
  mail_body4 | mail -s "NDSD Total threads is equal to max-threads on $host" -r $mfrom $email
  logit "NDSD Total threads are equal to the n4u.server.max-threads setting. This means NDSD cannot spawn new threads. You may need to increase the value of n4u.server.max-threads using ndsconfig set to resolve this issue."
else
  logit "NDSD Total threads are below the number max-threads at this time, there is no additional action required at this time."
fi

# Delete temporary file
rm -f $ncpthreads
rm -f $ndsthreads
rm -f $ndsmaxthreads

exit 0
