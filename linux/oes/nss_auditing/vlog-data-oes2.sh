#!/bin/bash - 
#============================================================================
#
#          FILE: vlog-data-oes2.sh
# 
#         USAGE: ./vlog-data-oes2.sh 
# 
#   DESCRIPTION: Script to run NSS Vigil logging on OES2 
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
#       OPTIONS: Cron the script t start at midnight, every day.
#          CRON: 0 0 * * * /root/bin/vlog-data-oes2.sh
#  REQUIREMENTS: Make sure you customize the data_filter correctly!
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue May 22 2018 14:52
#  LAST UPDATED: Thu May 24 2018 09:00
#       VERSION: 0.1.1
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#============================================================================
ts=$(date +"%Y%m%d_%h%k%M")            # general date|time stamp
host=$(hostname)                       # hostname of the local server
log=/var/log/audit/vlog                # log name and location (if required)
vlogbin=/opt/novell/vigil/bin          # path to vigil binaries
#============================================================================
# Make sure the novell-vigil daemon is enabled
/sbin/chkconfig novell-vigil on

# Start the novell-vigil daemon if it is not running
/etc/init.d/novell-vigil status &>/dev/null
  vigilReturnCode=$?
if [ $vigilReturnCode == "0" ]; then
  echo "novell-vigil service is running" > /dev/null
else
  echo "novell-vigil is not running on $host, attempting a start now" > /dev/null
  /etc/init.d/novell-vigil start
  echo "novell-vigil started"
fi

# Start the vlog process
$vlogbin/vlog -a -f CSV -p":-all" -F /root/bin/data_filter -o $log/nss-audit.csv

# Run vlog for 23 hours and 59 minutes and then shut it down
sleep 86340
killall -s SIGTERM "$(pidof vlog)"

# timestamp the log file for future collection.
mv $log/nss-audit.csv $log/nss-audit_"$ts".csv

# Generate a md5sum and sha256sum on the new log

# Finished
exit 0
