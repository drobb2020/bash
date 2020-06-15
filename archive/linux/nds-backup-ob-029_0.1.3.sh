#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-backup-ob.sh
# 
#         USAGE: ./nds-backup-ob.sh 
# 
#   DESCRIPTION: Backup selected eDirectory object or a container from an OES Server
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
#       CREATED: Tue Sep 17 2013 08:12
#  LAST UPDATED: Mon Jul 20 2015 15:43
#      REVISION: 3
#     SCRIPT ID: 029
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=029                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/nds-backup-ob-$1-$ds.log'     # logging (if required)
ds=$(date +%a)                              # Abreviated day of the week
df=$(date +%A)                              # Full day of the week
ndsconf=/etc/opt/novell/eDirectory/conf     # Path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin           # Path to eDirectory binaries
fn=$host-$1-$df                             # File name
admin=                                      # Administrator account FQN
pswd=                                       # Administrator's password

# Create the necessary folders
if [ -d /backup/nds ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$host/nds
fi

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
	echo "--[ Help ]---------------------------------"
	echo "The correct command line syntax is: "
	echo "./nds-backup-ob.sh <edirectoryobject>"
	echo "for example ./nds-backup-ob.sh OU=ECS.O=CEN"
	echo "==========================================="
	exit 1
}

initlog

# Backup eDirectory objects
if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  $ndsbin/ndsbackup cvf /backup/$host/nds/$fn -a $admin -p $pswd $1 | tee -a $log
fi

# E-mail results
if [ -n "$email" ]; then
  mail -s "NDS Backup log for $host" $email < $log
fi

echo "-------------------------------------------------------------------------------------------------" >> $log

# Finished
exit 1

