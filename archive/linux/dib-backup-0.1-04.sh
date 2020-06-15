#!/bin/bash
REL=0.1-04
##############################################################################
#
#    dib-backup.sh - Backup the DIB set and NICI on an OES server
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
# Date Created: Tue Oct 02 14:32:42 2012
# Last updated: Thu Sep 12 08:21:28 2013 
# Suggested Crontab command: 00 3 * * * /root/bin/dib-backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DS=$(date +%a)
DF=$(date +%A)
HOST=$(hostname)
FN=$HOST$DOWF
PSWD=
EMAIL=

# Create the necessary folders
if [ -d /backup/dib ]
    then
	echo "Directory exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /backup/dib
fi

if [ -d /var/log/dibbackup ]
    then
	echo "Directoru exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /var/log/dibbackup
fi

# Backup the DIB set and NICI key each day of the week
/opt/novell/eDirectory/bin/dsbk backup -b -f /backup/dib/$FN.dib -l /var/log/dibbackup/$DF.log -e $PSWD -t -w

# E-mail results
if [ -n "$EMAIL" ]
    then
	mail -s "DIB and NICI Backup log for $HOST" $EMAIL < /var/log/dibbackup/$DF.log
fi

# Finished
exit

