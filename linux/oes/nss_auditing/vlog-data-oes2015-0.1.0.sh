#!/bin/bash - 
#===============================================================================
#
#          FILE: vlog-data-oes2015.sh
# 
#         USAGE: ./vlog-data-oes2015.sh 
# 
#   DESCRIPTION: Script to run NSS Vigil logging on OES2015 
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
#          CRON: 0 0 * * * /root/bin/vlog-data-oes2015.sh
#  REQUIREMENTS: Make sure you customize the data_filter correctly!
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue May 22 2018 14:23
#   LAST UDATED: Thu May 24 2018 09:13
#       VERSION: 0.1.1
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.1                                    # version number of the script
sid=000                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$$(date +"%Y%m%d_%T")                         # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=nss-logging                                # email sender
email=root                                       # email recipient(s)
log=/var/log/audit/vlog                          # log name and location (if required)
vlogbin=/opt/novell/vigil/bin                    # path to vlog binary
#===============================================================================
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
$vlogbin/vlog -d -a -f CSV -F /root/bin/data_filter -p":-all" -o $log/nss-audit.csv

# Run vlog for 23 hours and 59 minutes and then shut it down
sleep 86340
kill -s SIGTERM `pidof vlog`

# timestamp the log file for future collection.
mv $log/nss-audit.csv $log/nss-audit-$ts.csv

# generate md5 and sha256 checksums on the new log
/usr/bin/md5sum $log/nss-audit-$ts.csv >> $log/nss-audit-$ts.md5
/usr/bin/sha256sum $log/nss-audit-$ts.csv >> $log/nss-audit-$ts.sha256

# email the files to recipients
function mail_body1() { 
echo -e "Please find attacted the vigil audit log for $date from server $host. \n\nThis log should be treated as evidence, and handled according to chain of evidence requirements."
}
mail_body1 | mail -s "NSS Vigil Audit log from $host" -a $log/nss-audit-$ts.csv -a $log/nss-audit-$ts.md5 -a $log/nss-audit-$ts.sha256 -r $mfrom $email

# Finished
exit 1

