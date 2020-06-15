#!/bin/bash
REL=0.1-04
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
# Last updated: Tue Jun 04 11:48:00 2013 
# Suggested Crontab command: 30 3 * * * /root/bin/nds-backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DOWS=$(date +%a)
DOWF=$(date +%A)
HOST=$(hostname)
NDSCONF=/etc/opt/novell/eDirectory/conf/nds.conf
NDSBIN=/opt/novell/eDirectory/bin
ADMIN=admin.dev
PW=nashira!=000
TREE=dev-tree
CNTXT='ou=accts.o=development'
FN=$TREE$DOWF
EMAIL=root

# Create the necessary folders
if [ -d /backup/nds ]
    then
	echo "Directory exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /backup/nds
fi

# Backup eDirectory objects
$NDSBIN/ndsbackup cvf /backup/nds/$FN -a $ADMIN -p $PW

# Finished
exit

