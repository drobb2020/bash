#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-collect.sh
# 
#         USAGE: ./sc-collect.sh 
# 
#   DESCRIPTION: Run supportutils on a scheduled basis
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
#       OPTIONS: 0 5 25 * * /root/bin/sc-collect.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Mar 24 2011 14:48
#  LAST UPDATED: Tue Jul 21 2015 10:10
#      REVISION: 7
#     SCRIPT ID: 037
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.7
sid=037                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/sc-collect.sh.log'            # logging (if required)
repdir=/var/log                             # 
cpdir=/root/reports
incdir=/root/bin

# Delete last month's supportconfig report
if [ -e /var/log/nts_$host_*.tbz ]; then
  /bin/rm $repdir/nts_$host_*.tbz
  /bin/rm $repdir/nts_$host_*.tbz.md5
  cd /root/reports/
  /bin/rm -R $(ls | grep nts)
else
  echo "Previous files do not exist - continuing..."
fi

#Update supportutils before running it. Requires Internet access
/sbin/updateSupportutils -u
/usr/bin/clear

# Run the script
/sbin/supportconfig -Q

# E-mail supportconfig
if [ -n $email ]; then
  echo -e "Please find attached this month's Support Config Report for $host. Please store this file for historical reference.\nThis file can also be sent to Novell for additional support in the following manners:\n1. E-mail the tar ball to the assigned engineer\n2. Upload to ftp://ftp.novell.com/incoming (include SR# in name of file)\n3. Attach it to the Service Request at https://secure-support.novell.com/eService_enu\n4. Use the following command: supportconfig -ur <SR#>\nThe results of the collection can also be viewed on the server in /root/reports/nts_<server_name>_<date_stamp>." | mail -s "$host Supportconfig Report" -a /var/log/nts_*.tbz $email

# Finished
exit 0

