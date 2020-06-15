#!/bin/bash - 
#===============================================================================
#
#          FILE: dib-restore.sh
# 
#         USAGE: ./dib-restore.sh 
# 
#   DESCRIPTION: Restore eDirectory and NICI on an OES server from a previous backup.
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
#       CREATED: Tue Oct 02 2012 14:32
#  LAST UPDATED: Sun Jun 19 2016 12:51
#      REVISION: 5
#     SCRIPT ID: 024
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.6
sid=024                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/dib-restore.log'                  # logging (if required)
pswd=                                           # Password for NICI keys, should be the same as in the dib-backup.sh script

function helpme() {
  echo "WARNING"
  echo "-------------------------------------------------------------------"
  echo "The correct command line syntax is ./dib-restore.sh /path/to/dib"
  echo "for example ./dib-restore.sh /backup/dib/acpic-s2740Tuesday.dib"
  echo "==================================================================="
  exit 1
}

if [ $# -lt 1 ]; then
  echo "There are not enough options on the command line."
	helpme
else	
  /opt/novell/eDirectory/bin/dsbk restore -r -f /backup/dib/$1.dib -l /var/log/dibbackup/$df.log -d /var/rfl/logs -e $pswd -a -o
fi

# E-mail results
if [ -n "$email" ]; then
  mail -s "DIB Restore performed on $host" $email < /var/log/dibbackup/$df.log
fi

# Finished
exit 1

