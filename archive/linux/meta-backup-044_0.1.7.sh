#!/bin/bash - 
#===============================================================================
#
#          FILE: meta-backup.sh
# 
#         USAGE: ./meta-backup.sh 
# 
#   DESCRIPTION: Backup all NSS metadata for the volumes listed on the command line
#
#                Copyright (C) 2016  David Robb
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
#       OPTIONS: 00 4 * * * /root/bin/meta-backup.sh VOL1 VOL2
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Oct 02 2012 14:34
#  LAST UPDATED: Sun Jun 19 2016 14:25
#      REVISION: 6
#     SCRIPT ID: 044
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.7
sid=044                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/meta-backup.log'                  # logging (if required)

# Create folder structure if it doesn't exist
if [ -d /backup/$host/metadata/$ds ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$host/metadata/$ds
fi

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
    /sbin/metamig save "$1" -m a > /backup/$host/metadata/$ds/$1
    shift
  done
fi

# E-mail results
if [ -n "$email" ]; then
  echo -e "NSS metadata has been backed up on $host.\nThe files can be found under /backup/$host/metadata/$ds.\nThese files can be used to perform a restore is the volume metadata become corrupt." | mail -s "NSS Metadata Backup log for $host" $email
fi

# Finished
exit 1

