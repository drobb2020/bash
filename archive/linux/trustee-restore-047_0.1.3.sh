#!/bin/bash - 
#===============================================================================
#
#          FILE: trustee-restore.sh
# 
#         USAGE: ./trustee-restore.sh 
# 
#   DESCRIPTION: Restore NSS Trustee data for a volume. This is not the same as using metamig!
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
#       CREATED: Tue Jul 21 2015 14:38
#  LAST UPDATED: Sun Jun 19 2016 14:37
#      REVISION: 2
#     SCRIPT ID: 047
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.3
sid=047                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/trustee-restore.log'              # logging (if required)

function helpme() { 
  echo "--[ Help ]------------------------------------"
  echo "The correct command line syntax is: "
  echo "./trustee-restore.sh <day of week> VOL1"
  echo "for example ./trustee-restore.sh Tuesday DATA"
  echo "Please remember Volumes are case-sensitive"
  echo "on Linux."
  echo "=============================================="
  exit 1
}

if [ $# -lt 2 ]; then
  echo "There are not enough options on the command line" >> /dev/stderr
  helpme
else
	/bin/zTrustee /R ALL RESTORE ALL /backup/$host/trustee/$1/$2-backup
fi

exit 1

