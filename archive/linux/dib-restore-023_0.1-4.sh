#!/bin/bash
REL=0.1-4
SID=023
##############################################################################
#
#    dib-restore.sh - Restore eDirectory and NICI on an OES server from a 
#                     previous backup.
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
# Last updated: Wed May 27 13:09:02 2015 
# Suggested Crontab command: Not recommended, run only as required
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DS=$(date +%a)
DF=$(date +%A)
HOST=$(hostname)
EMAIL=
PSWD=

/opt/novell/eDirectory/bin/dsbk restore -r -f /backup/dib/$1.dib -l /var/log/dibbackup/$DF.log -d /var/rfl/logs -e $PSWD -a -o

# E-mail results
if [ -n "$EMAIL" ]; then
  mail -s "DIB Restore performed on $HOST" $EMAIL < /var/log/dibbackup/$DOWF.log
fi

# Finished
exit 1

