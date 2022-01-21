#!/bin/bash - 
#===============================================================================
#
#          FILE: trustee-backup.sh
# 
#         USAGE: ./trustee-backup.sh 
# 
#   DESCRIPTION: Backup all NSS Trustee data for all volumes. 
#                This is not the same as using metamig!
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
#       OPTIONS: 0 5 * * * /root/bin/trustee_backup.sh VOL1 VOL2 VOL3
#  REQUIREMENTS: ztrustee binary
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Oct 02 2012 14:38
#  LAST UPDATED: Thu Mar 15 2018 08:49
#       VERSION: 0.1.5
#     SCRIPT ID: 046
# SSC SCRIPT ID: 00
#===============================================================================
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
mfrom=nss-trustee-backup                         # email sender
email=root                                       # email recipient(s)
#===============================================================================

# Create backup folder structure if it doesn't exist
if [ -d /backup/"$host"/trustee/"$df" ]
then
	echo "Directory exists, continuing ..." >> /dev/null
else
	/bin/mkdir -p /backup/"$host"/trustee/"$df"
fi

# test for the existence of ztrustee
function ztinst(){ 
if [ -f /bin/zTrustee ]; then
  echo "zTrustee installed, continuing..." >> /dev/stderr
else
  echo "--[ WARNING ]---------------------------------"
  echo "The zTrustee application is not installed."
  echo "This script will not function without it."
  echo "The script will now exit."
  echo "=============================================="
  exit 1
fi
}

# Command help statement
function helpme() { 
  echo "--[ Help ]------------------------------------"
  echo "The correct command line syntax is: "
  echo "./trustee-backup.sh VOL1 VOL2 VOL3 ..."
  echo "for example ./trustee-backup.sh APPS DATA USER"
  echo "Please remember Volumes are case-sensitive"
  echo "on Linux."
  echo "=============================================="
  exit 1
}

# Test to see if zTrustee in present on the server
ztinst

# Save metadata for each volume listed on the command line
if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  while test -n "$1"
  do
    /bin/zTrustee /ET SAVE "$1:" /root/"$1"-backup
  shift
  done
fi

# mail message
function mail_body1() { 
echo -e "NSS trustee's has been backed up on $host.\nThe files can be found under /backup/$host/trustee/$df.\nThese files can be used to perform a restore if the volume trustee's become corrupt."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NSS Trustee Backup Report for $host" -r $mfrom $email
fi

# Finished
exit 0
