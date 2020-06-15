#!/bin/bash - 
#===============================================================================
#
#          FILE: meta-restore.sh
# 
#         USAGE: ./meta-restore.sh 
# 
#   DESCRIPTION: Restore all NSS metadata for the volumes included on the command line
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
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Oct 02 2012 14:34
#  LAST UPDATED: Sun Jun 19 2016 14:27
#      REVISION: 3
#     SCRIPT ID: 045
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=045                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/meta-restore.log'                 # logging (if required)

function helpme() { 
	echo "--[ Help ]--------------------------------------------"
	echo "The correct command line syntax is: "
	echo "./meta-restore.sh <day of the week> VOL1 VOL2 VOL3 ..."
	echo "for example ./meta-restore.sh Tue APPS DATA USER"
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
if [ -n "$email" ]; then
  echo -e "NSS metadata has been restored on $host.\nPlease verify that users still have access to thier files." | mail -s "NSS Metadata Backup log for $host" $email
fi

# Finished
exit 1

