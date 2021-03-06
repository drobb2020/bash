#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-restore-ob.sh
# 
#         USAGE: ./nds-restore-ob.sh 
# 
#   DESCRIPTION: Restore a single eDirectory object to an OES server
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
#       CREATED: Mon Sep 16 2013 14:46
#  LAST UPDATED: Tue Jul 21 2015 08:26
#      REVISION: 2
#     SCRIPT ID: 031
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.2
sid=031                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/nds-restore-ob-$df.log'       # logging (if required)
ds=$(date +%a)                              # Abreviated day of the week
df=$(date +%A)                              # Full day of the week
ndsconf=/etc/opt/novell/eDirectory/conf     # Path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin           # Path to nds binaries
fn=$HOST$DF                                 # File name
admin=                                      # Administrators account name FQN
pswd=                                       # Administrators password

function initlog() { 
  if [ -e $log ]; then
    echo "log file exists"
  else
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function helpme() { 
  echo "The correct command line syntax is: "
  echo "./nds-restore <hostnamedayofweek> <edirectoryobject>"
  echo "for example ./nds-restore.sh acpic-s779Thursday CN=000212363.OU=ECS.O=CEN"
  exit 1
}

initlog

# Restore single eDirectory object
if [ $# -lt 2 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  $ndsbin/ndsbackup xvfw /backup/$host/nds/$1 -a $admin -p $pswd $2 | tee -a $log
fi

# E-mail results
if [ -n "$email" ]; then
  mail -s "NDS Backup log for $host" $email < $log
fi

echo "-------------------------------------------------------------------------------------------------" >> $log

# Finished
exit 1

