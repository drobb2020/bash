#!/bin/bash
REL=0.1-04
##############################################################################
#
#    supportrep.sh - Run supportutils on a scheduled basis
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
# Last updated: Tue Jun 04 12:31:58 2013 
# Crontab command: 0 5 25 * * /root/bin/supportrep.sh
# Supporting file: /root/bin/supportmsg.txt
# Additional Notes: Don't forget to set your custom variables for you environment.
##############################################################################
# Declare variables
HOST=$(hostname)

# Custom variables
EMAIL=edirreports@excs2net.org
REPDIR=/var/log
CPDIR=/root/reports
INCDIR=/root/bin

# Delete last month's supportconfig report
if [ -e /var/log/nts_$HOST_*.tbz ]
		then
		/bin/rm $REPDIR/nts_$HOST_*.tbz
		/bin/rm $REPDIR/nts_$HOST_*.tbz.md5
		cd /root/reports/
                /bin/rm -R $(ls | grep nts)
		else
			echo "files do not exist - continuing..."
fi

#Update supportutils before running it. Requires Internet access
/sbin/updateSupportutils -u
/usr/bin/clear

# Run the script
/sbin/supportconfig -Q

# Copy and unpack the report for local use
cp /var/log/nts_*.tbz /root/reports/
cd /root/reports/
/bin/tar xjvf $(ls | grep nts)

# Remove the tarball
/bin/rm /root/reports/*.tbz

# E-mail the report
# mail -s "$HOST Supportconfig Report" -a /var/log/nts_*.tbz $EMAIL <$INCDIR/supportmsg.txt

# Finished
exit

