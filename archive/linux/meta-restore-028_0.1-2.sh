#!/bin/bash
REL=0.1-2
SID=028
##############################################################################
#
#    meta-restore.sh - Restore all NSS metadata for the volumes included on the 
#                      command line when you run the script.
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
# Date Created: Tue Oct 02 14:34:02 2012
# Last updated: Wed May 27 13:38:44 2015 
# Suggested Crontab command: not recommended, restores should be done manually
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DS=$(date +%a)
DF=$(date +%A)

function helpme() { 
	echo "--[ Help ]--------------------------------------------"
	echo "The correct command line syntax is: "
	echo "./meta-restore.sh <day of the week> VOL1 VOL2 VOL3 ..."
	echo "for example ./meta-backup.sh Tue APPS DATA USER"
	echo "Please remember Pools and Volumes are case-"
	echo "sensitive on Linux."
	echo "======================================================"
	exit 1
}

# Restore NSS Metadata for each volume listed on the command line
if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  while test -n "$2"
  do
    /sbin/metamig restore "$2" -m a -d < /backup/metadata/$1/$2
  shift
  done
fi

# E-mail results
if [ -n "$EMAIL" ]; then
  echo -e "NSS metadata has been restored on $HOST.\nPlease verify that users still have access to thier files." | mail -s "NSS Metadata Backup log for $HOST" $EMAIL
fi

# Finished
exit 1

