#!/bin/bash - 
#===============================================================================
#
#          FILE: dib-restore.sh
# 
#         USAGE: ./dib-restore.sh 
# 
#   DESCRIPTION: Restore eDirectory and NICI on an OES server from a previous backup.
#
#                Copyright (C) 2015  David Robb
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
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Oct 02 2012 14:32
#  LAST UPDATED: Mon Jul 20 2015 12:26
#      REVISION: 5
#     SCRIPT ID: 024
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.5
sid=024                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/dib-restore.log'              # logging (if required)
DS=$(date +%a)                              # Abreviated day of the week
DF=$(date +%A)                              # Full day of the week
PSWD=                                       # Password for NICI keys, should be the same as in the dib-backup.sh script

/opt/novell/eDirectory/bin/dsbk restore -r -f /backup/dib/$1.dib -l /var/log/dibbackup/$DF.log -d /var/rfl/logs -e $PSWD -a -o

# E-mail results
if [ -n "$email" ]; then
  mail -s "DIB Restore performed on $host" $email < /var/log/dibbackup/$DF.log
fi

# Finished
exit 1

