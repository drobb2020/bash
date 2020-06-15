#!/bin/bash
REL=0.1-07
##############################################################################
#
#    nds-backup.sh - Backup eDirectory objects from an OES Server
#    Copyright (C) 2013  David Robb
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
# Date Created: Tue Feb 12 16:48:37 2013 
# Last updated: Wed Oct 30 08:33:39 2013 
# Suggested Crontab command: 30 3 * * * /root/bin/nds-backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DS=$(date +%a)
DF=$(date +%A)
TS=$(date +"%b %d %T")
HOST=$(hostname)
NDSCONF=/etc/opt/novell/eDirectory/conf/nds.conf
NDSBIN=/opt/novell/eDirectory/bin
FN=$HOST-Full-$DF
ADMIN="cn=admin.o=excs"
PW=nashira!=000
EMAIL=root
USER=$(whoami)
LOG=/var/log/ndsbackup/ndsbackup-full-$DS.log

# Create the necessary folders
if [ -d /backup/nds ]
    then
	echo "Directory exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /backup/$HOST/nds
fi

if [ -d /var/log/ndsbackup ]
    then
	echo "Directoru exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /var/log/ndsbackup
fi

function initlog() { 
   if [ -e /var/log/ndsbackup/ndsbackup-full-$DS.log ]
	then
		echo "log file exists"
	else
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

initlog

# Backup eDirectory objects
$NDSBIN/ndsbackup cvf /backup/$HOST/nds/$FN -a $ADMIN -p $PW | tee -a $LOG

# E-mail results
if [ -n "$EMAIL" ]
    then
	mail -s "NDS Backup log for $HOST" $EMAIL < $LOG
fi

echo "-------------------------------------------------------------------------------------------------" >> $LOG

# Finished
exit

