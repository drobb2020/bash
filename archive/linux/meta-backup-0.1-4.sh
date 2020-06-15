#!/bin/bash
REL=0.1-04
##############################################################################
#
#    meta-backup.sh - Backup all NSS metadata for the volumes included on the 
#                     command line when you run the script.
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
# Last updated: Tue Sep 17 11:24:06 2013 
# Suggested Crontab command: 00 4 * * * /root/bin/meta-backup.sh VOL1 VOL2
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare variables
DS=$(date +%a)
DF=$(date +%A)
HOST=$(hostname)
EMAIL=root

# Create folder structure if it doesn't exist
if [ -d /backup/$HOST/metadata/$DS ]
then
	echo "Directory exists, continuing ..." >> /dev/null
else
	/bin/mkdir -p /backup/$HOST/metadata/$DS
fi

function helpme() { 
	echo "--[ Help ]---------------------------------"
	echo "The correct command line syntax is: "
	echo "./meta-backup.sh VOL1 VOL2 VOL3 ..."
	echo "for example ./meta-backup.sh APPS DATA USER"
	echo "Please remember Pools and Volumes are case-"
	echo "sensitive on Linux."
	echo "==========================================="
	exit 1
}

# Save metadata for each volume listed on the command line
if [ $# -lt 1 ] 
    then
	echo "There are not enough arguments on the command line." > /dev/stderr
	helpme
    else
	while test -n "$1"
   	    do
     		/sbin/metamig save "$1" -m a > /backup/$HOST/metadata/$DS/$1
     		shift
   	    done
fi

# E-mail results
if [ -n "$EMAIL" ]
    then
	echo -e "NSS metadata has been backed up on $HOST.\nThe files can be found under /backup/$HOST/metadata/$DF.\nThese files can be used to perform a restore is the volume metadata become corrupt." | mail -s "NSS Metadata Backup log for $HOST" $EMAIL
fi

# Finished
exit


