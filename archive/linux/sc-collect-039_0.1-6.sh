#!/bin/bash
REL=0.1-6
SID=039
##############################################################################
#
#    sc-collect.sh - Run supportutils on a scheduled basis
#    Copyright (C) 2012  David Robb
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#
##############################################################################
# Date Created: Thu Mar 24 14:48:23 2011 
# Last updated: Wed May 27 14:50:03 2015 
# Crontab command: 0 5 25 * * /root/bin/supportrep.sh
# Supporting file: /root/bin/supportmsg.txt
# Additional Notes: Don't forget to set your custom variables for you environment.
##############################################################################
# Declare variables
HOST=$(hostname)
EMAIL=root
REPDIR=/var/log
CPDIR=/root/reports
INCDIR=/root/bin

# Delete last month's supportconfig report
if [ -e /var/log/nts_$HOST_*.tbz ]; then
  /bin/rm $REPDIR/nts_$HOST_*.tbz
  /bin/rm $REPDIR/nts_$HOST_*.tbz.md5
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
if [ -n $EMAIL ]; then
  echo -e "Please find attached this month's Support Config Report for $HOST. Please store this file for historical reference.\nThis file can also be sent to Novell for additional support in the following manners:\n1. E-mail the tar ball to the assigned engineer\n2. Upload to ftp://ftp.novell.com/incoming (include SR# in name of file)\n3. Attach it to the Service Request at https://secure-support.novell.com/eService_enu\n4. Use the following command: supportconfig -ur <SR#>\nThe results of the collection can also be viewed on the server in /root/reports/nts_<server_name>_<date_stamp>." | mail -s "$HOST Supportconfig Report" -a /var/log/nts_*.tbz $EMAIL

# Finished
exit 0

