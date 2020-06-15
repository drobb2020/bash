#!/bin/bash - 
#===============================================================================
#
#          FILE: oes-mem-mon.sh
# 
#         USAGE: ./oes-mem-mon.sh 
# 
#   DESCRIPTION: monitor the memory usage on an OES server
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
#       OPTIONS: This script should be run via cron every 5,10, or 15 minutes as needed
#  REQUIREMENTS: This script requires smem to be installed to collect swap information
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Mar 21 2016 15:14
#   LAST UDATED: Thu May 07 2020 09:07
#       VERSION: 0.1.4
#     SCRIPT ID: 071
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.4                                    # version number of the script
sid=071                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=memory-monitor                             # email sender
email=root                                       # email recipient(s)
log='/var/log/oes-mem-mon.log'                   # log name and location (if required)
#===============================================================================

# Initialize logging
function initlog() { 
  if [ -e ${log} ]; then
    echo "log file exists" > /dev/null
  else
    touch ${log}
    echo " " >> ${log}
  fi
}

function logit() { 
	echo -e $* >> ${log}
}

initlog
# log heading
echo "OES Memory Monitoring Script to collect data in case of an OOM Condition" >> ${log}
echo "Report is being generated for $host" >> ${log}
echo "Logging started at $ts" >> ${log}
echo "All actions are being run as $user" >> ${log}
echo " " >> ${log}

# Generate a report of installed and used memory
logit "========================================================================"
logit "Output of free"
logit "------------------------------------------------------------------------"
/usr/bin/free -mot >> $log
echo " " >> ${log}

# Generate a report using ps
logit "========================================================================"
logit "Output of ps aux"
logit "------------------------------------------------------------------------"
/bin/ps aux >> $log
echo " " >> ${log}

# Generate a report using slabinfo
logit "========================================================================"
logit "Output of /proc/slabinfo"
logit "------------------------------------------------------------------------"
/bin/cat /proc/slabinfo >> $log
echo " " >> ${log}

# Generate a report using meminfo
logit "========================================================================"
logit "Output of /proc/meminfo"
logit "------------------------------------------------------------------------"
/bin/cat /proc/meminfo >> $log
echo " " >> ${log}

# Generate a report of what is using swap memory
logit "========================================================================"
logit "Output of smem"
logit "------------------------------------------------------------------------"
/usr/local/bin/smem >> $log
echo " " >> ${log}

logit "Logging complete at $(date +"%b %d %T")"

# Finished
exit 1

