#!/bin/bash - 
#===============================================================================
#
#          FILE: edir-procwatch.sh
# 
#         USAGE: ./edir-procwatch.sh 
# 
#   DESCRIPTION: Script to monitor and log the utilization of ndsd and ncp2nss
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
#       OPTIONS: */5 * * * * ~/bin/edir-procwatch.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Mar 03 2015 11:44
#  LAST UPDATED: Fri Jul 17 2015 13:13
#      REVISION: 2
#     SCRIPT ID: 006
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.2
sid=006                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/edir-procwatch.log'           # logging (if required)

function initlog() { 
if [ -e $log ]; then
  echo "log file exists" > /dev/null
else
	echo "Logging started at ${ts}" > ${log}
	echo "All actions are being performed by the user: ${user}" >> ${log}
	echo " " >> ${log}
fi
}

function logit() { 
	echo $TS $HOST $* >> ${log}
}
initlog

# get the pids of ndsd and ncp2nss
/bin/pidof ndsd >/tmp/ndsd.pid
/bin/pidof ncp2nss > /tmp/ncp2.pid
P1=$(cat /tmp/ndsd.pid | awk '{print $1}')
P2=$(cat /tmp/ncp2.pid | awk '{print $1}')

# Run top in batch mode and log the results for the two pids
/usr/bin/top -b -n1 -p${P1} -p${P2} > ${log}

exit 1

