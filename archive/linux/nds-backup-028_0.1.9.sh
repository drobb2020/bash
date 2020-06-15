#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-backup.sh
# 
#         USAGE: ./nds-backup.sh 
# 
#   DESCRIPTION: Backup all eDirectory objects from an OES Server
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
#       CREATED: Tue Feb 12 2013 16:48
#  LAST UPDATED: Sun Jun 19 2016 13:12
#      REVISION: 8
#     SCRIPT ID: 028
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.9
sid=028                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
ndsconf=/etc/opt/novell/eDirectory/conf         # Path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin               # Path to eDirectory binaries
fn=$host-full-$df                               # File name
admin=                                          # Administrator account
pswd=                                           # Administrator's password
email=root                                      # who to send email to (comma separated list)
log='/var/log/nds-backup.log'                   # logging (if required)

# Create the necessary folders
if [ -d /backup/nds ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$host/nds
fi

if [ -d /var/log/ndsbackup ]; then
  echo "Directoru exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /var/log/ndsbackup
fi

function initlog() { 
  if [ -e ${log} ]; then
    echo "log file exists"
  else
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

initlog

# Backup eDirectory objects
$ndsbin/ndsbackup cvf /backup/$host/nds/$fn -a $admin -p $pswd | tee -a $log

# E-mail results
if [ -n "$email" ]; then
  mail -s "NDS Backup log for $host" $email < $log
fi

echo "-------------------------------------------------------------------------------------------------" >> $LOG

# Finished
exit 1

