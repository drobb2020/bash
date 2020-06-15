#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-backup.sh
# 
#         USAGE: ./nds-backup.sh 
# 
#   DESCRIPTION: Backup all eDirectory objects from an OES Server
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
#       CREATED: Tue Feb 12 2013 16:48
#  LAST UPDATED: Mon Jul 20 2015 15:34
#      REVISION: 8
#     SCRIPT ID: 028
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.8
sid=028                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
ds=$(date +%a)                              # Abreviated day of the week
df=$(date +%A)                              # Full day of the week
ndsconf=/etc/opt/novell/eDirectory/conf     # Path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin           # Path to eDirectory binaries
fn=$host-full-$df                           # File name
admin=                                      # Administrator account
pswd=                                       # Administrator's password
log='/var/log/nds-backup-full-$DS.log'      # logging (if required)

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
  if [ -e /var/log/ndsbackup/ndsbackup-full-$ds.log ]; then
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

