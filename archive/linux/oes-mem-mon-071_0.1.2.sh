#!/bin/bash - 
#===============================================================================
#
#          FILE: oes-mem-mon.sh
# 
#         USAGE: ./oes-mem-mon.sh 
# 
#   DESCRIPTION: Script to monitor the memory usage on an OES server
#
#                Copyright (C) 2016  David Robb
#
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
#       OPTIONS: This script should be run via cron every 5,10, or 15 minutes as needed
#  REQUIREMENTS: This script requires smem to be installed to collect swap information
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Mon Mar 21 2016 15:14
#  LAST UPDATED: Sun Jun 19 2016 14:51
#      REVISION: 1
#     SCRIPT ID: 071
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.2
sid=071                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/oes-mem-mon.log'                  # logging (if required)

function initlog() { 
   if [ -e ${log} ]
	then
		echo "log file exists" > /dev/null
	else
		touch ${log}
		echo "Logging started at ${ts}" > ${log}
		echo "All actions are being performed by the user: ${user}" >> ${log}
		echo " " >> ${log}
    fi
}

function logit() { 
	echo -e $ts $host: $* >> ${log}
}

initlog
logit "OES Memory Monitoring Script to collect data in case of an OOM Condition"
logit "========================================================================"
logit "Logging started at $ts"
logit "========================================================================"
logit "Output of ps aux"
logit "------------------------------------------------------------------------"
/bin/ps aux >> $log

logit "========================================================================"
logit "Output of free -mot"
logit "------------------------------------------------------------------------"
/usr/bin/free -mot >> $log

logit "========================================================================"
logit "Output of /proc/slabinfo"
logit "------------------------------------------------------------------------"
/bin/cat /proc/slabinfo >> $log

logit "========================================================================"
logit "Output of /proc/meminfo"
logit "------------------------------------------------------------------------"
/bin/cat /proc/meminfo >> $log

logit "========================================================================"
logit "Output of smem"
logit "------------------------------------------------------------------------"
/usr/local/bin/smem >> $log

logit "========================================================================"
logit "Logging complete at $ts"
logit "========================================================================"

exit 1

