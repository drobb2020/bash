#!/bin/bash - 
#===============================================================================
#
#          FILE: edir-procwatch.sh
# 
#         USAGE: ./edir-procwatch.sh 
# 
#   DESCRIPTION: Script to monitor and log the utilization of ndsd and ncp2nss
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
#       OPTIONS: */5 * * * * ~/bin/edir-procwatch.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Mar 12 2018 08:03
#   LAST UDATED: Mon Mar 12 2018 08:06
#       VERSION: 0.1.4
#     SCRIPT ID: 006
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.4                                    # version number of the script
sid=006                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=eDir-process-watcher                       # email sender
email=root                                       # email recipient(s)
log='/var/log/edir-procwatch.log'                # log name and location (if required)
#===============================================================================

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

