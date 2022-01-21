#!/bin/bash - 
#===============================================================================
#
#          FILE: meta-backup.sh
# 
#         USAGE: ./meta-backup.sh 
# 
#   DESCRIPTION: Backup all NSS metadata for the volumes listed on the command line
#
#                Copyright (c) 2018, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: 00 4 * * * /root/bin/meta-backup.sh VOL1 VOL2
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Oct 02 2012 14:34
#  LAST UPDATED: Thu Mar 15 2018 08:30
#       VERSION: 0.1.8
#     SCRIPT ID: 044
# SSC SCRIPT ID: 00
#===============================================================================
ds=$(date +%a)                                   # short day of the week eg. Mon
host=$(hostname)                                 # hostname of the local server
mfrom=nss-metadata-backup                        # email sender
email=root                                       # email recipient(s)
#===============================================================================
# Create folder structure if it doesn't exist
if [ -d /backup/"$host"/metadata/"$ds" ]; then
  echo "Directory exists, continuing..." >> /dev/null
else
  /bin/mkdir -p /backup/"$host"/metadata/"$ds"
fi

# command help statement
function helpme() { 
	echo "--[ HELP ]---------------------------------"
	echo "The correct command line syntax is: "
	echo "./meta-backup.sh VOL1 VOL2 VOL3 ..."
	echo "for example ./meta-backup.sh APPS DATA USER"
	echo "Please remember Pools and Volumes are case-"
	echo "sensitive on Linux."
	echo "==========================================="
	exit 1
}

# Save metadata for each volume listed on the command line
if [ $# -lt 1 ] ; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  while test -n "$1"
  do
    /sbin/metamig save "$1" -m a > /backup/"$host"/metadata/"$ds"/"$1"
    shift
  done
fi

# mail message
function mail_body1() { 
echo -e "NSS metadata has been backed up on $host.\nThe files can be found under /backup/$host/metadata/$ds.\nThese files can be used to perform a restore is the volume metadata become corrupt."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NSS Metadata Backup log for $host" -r $mfrom $email
fi

# Finished
exit 0
