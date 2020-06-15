#!/bin/bash - 
#===============================================================================
#
#          FILE: ztrustee-backup.sh
# 
#         USAGE: ./ztrustee-backup.sh VOL1 VOL2 VOL3
# 
#   DESCRIPTION: Backup all NSS Trustee data for all volumes. This is not the same as using metamig!
#
#                Copyright (C) 2015  David Robb
#
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: 0 5 * * * /root/bin/trustee_backup.sh VOL1 VOL2 VOL3
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Oct 02 2012 14:38
#  LAST UPDATED: Tue Jul 21 2015 14:37
#      REVISION: 3
#     SCRIPT ID: 046
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=046                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
ds=$(date +%a)                              # breviated day of the week, eg Mon
df=$(date +%A)                              # full day of the week, eg Monday
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/trustee-backup.log'           # logging (if required)

# Create folder structure if it doesn't exist
if [ -d /backup/$host/trustee/$df ]
then
	echo "Directory exists, continuing ..." >> /dev/null
else
	/bin/mkdir -p /backup/$host/trustee/$df
fi

function ztinst() { 
if [ -f /bin/zTrustee ]; then
  echo "zTrustee installed, continuing..." >> /dev/stderr
else
  echo "--[ WARNING ]---------------------------------"
  echo "The zTrustee application is not installed."
  echo "This script will not function without it."
  echo "The script will now exit."
  echo "=============================================="
  exit 1
}

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
    /bin/zTrustee /ET SAVE "$1:" /root/$1-backup
  shift
  done
fi

# E-mail results
if [ -n "$email" ]; then
  echo -e "NSS trustee's has been backed up on $host.\nThe files can be found under /backup/$host/trustee/$df.\nThese files can be used to perform a restore if the volume trustee's become corrupt." | mail -s "NSS Trustee Backup Report for $hsot" $email
fi

# Finished
exit

