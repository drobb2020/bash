#!/bin/bash - 
#===============================================================================
#
#          FILE: dib-backup.sh
# 
#         USAGE: ./dib-backup.sh 
# 
#   DESCRIPTION: Backup the DIB set and NICI files on an OES2/OES11 server
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
#       OPTIONS: 00 3 * * * /root/bin/dib-backup.sh
#  REQUIREMENTS: rfl must be configured on a server using this backup method
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: Remember to set a password to protect the NICI keys
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Oct 02 2012 14:32
#  LAST UPDATED: Sun Jun 19 2016 12:43
#      REVISION: 7
#     SCRIPT ID: 022
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.8
sid=022                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/dib-backup.log'                   # logging (if required)
NDSBIN=/opt/novell/eDirectory/bin               # Location of eDirectory binaries
FN=$HOST$DF                                     # Backup file filename
PSWD=                                           # Password to protect NICI keys

# Source in the dsbk prep script
. ~/bin/dsbkprep.sh

# Create the necessary folders
if [ -d /backup/$HOST/dib ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$HOST/dib
fi

if [ -d /var/log/dibbackup ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /var/log/dibbackup
fi

# Backup the DIB set and NICI keys each day of the week
$NDSBIN/dsbk backup -b -f /backup/$HOST/dib/$FN.dib -l /var/log/dibbackup/$DF.log -e $PSWD -t -w

# E-mail results
sleep 15
if [ -n "$email" ]; then
  mail -s "DIB and NICI Backup log for $host" $email < /var/log/dibbackup/$DF.log
fi

# Finished
exit 1

