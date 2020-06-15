#!/bin/bash
REL=0.1-02
##############################################################################
#
#    trustee_backup.sh - Backup all NSS Trustee data for all volumes.
#                        This is not the same as using metamig!
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
# Date Created: Tue Oct 02 14:38:17 2012
# Last updated: Thu Oct 24 11:37:56 2013 
# Suggested Crontab command: 0 5 * * * /root/bin/trustee_backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DS=$(date +%a)
DF=$(date +%A)
HOST=$(hostname)
EMAIL=root

# Create folder structure if it doesn't exist
if [ -d /backup/$HOST/trustee/$DS ]
then
	echo "Directory exists, continuing ..." >> /dev/null
else
	/bin/mkdir -p /backup/$HOST/trustee/$DS
fi

function helpme() { 
	echo "--[ Help ]---------------------------------"
	echo "The correct command line syntax is: "
	echo "./trustee-backup.sh VOL1 VOL2 VOL3 ..."
	echo "for example ./trustee-backup.sh APPS DATA USER"
	echo "Please remember Volumes are case-sensitive"
	echo "on Linux."
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
     		/bin/zTrustee /ET SAVE "$1" /backup/$HOST/metadata/$DS/$1
     		shift
   	    done
fi

# E-mail results
if [ -n "$EMAIL" ]
    then
	echo -e "NSS trustee's has been backed up on $HOST.\nThe files can be found under /backup/$HOST/trustee/$DF.\nThese files can be used to perform a restore if the volume trustee's become corrupt." | mail -s "NSS Trustee Backup Report for $HOST" $EMAIL
fi

# Finished
exit

