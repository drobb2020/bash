#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-restore.sh
# 
#         USAGE: ./nds-restore.sh 
# 
#   DESCRIPTION: Restore eDirectory objects to an OES server
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
#       CREATED: Mon Sep 16 2013 12:52
#  LAST UPDATED: Tue Jul 21 2015 08:18
#      REVISION: 3
#     SCRIPT ID: 030
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=030                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/nds-restore-$ds.log'          # logging (if required)
ds=$(date +%a)                              # Abreviated day of the week
df=$(date +%A)                              # Full day of the week
ndsconf=/etc/opt/novell/eDirectory/conf     # Path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin           # Path to nds binaries
fn=$host$df                                 # File name
admin=                                      # Administrators account name FQN
pswd=                                       # Administrator's password

function initlog() { 
  if [ -e $log ]; then
    echo "log file exists"
  else
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function warning() {
	echo "--[ WARNING ]--------------------------------------------------------"
	echo "This script will restore the entire eDirectory tree."
	echo "This should only be done if the tree has been damaged beyond repair,"
	echo "and all objects have been lost."
	echo "If you need to restore an individual object or a sub container please"
	echo "refer to the man pages for ndsbackup (man ndsbackup)."
	echo "====================================================================="
}

function helpme() { 
	echo "The correct command line syntax is ./nds-restore <hostnamedayofweek>"
	echo "for example ./nds-restore.sh acpic-s779Thursday"
	exit 1
}

initlog

# Restore eDirectory objects
if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  warning
  while true
  do
    read -p "Do you wish to continue with the nds restore? (y/n) " YN
    echo "==============================================="
    case $YN in
    [Yy]* ) $ndsbin/ndsbackup xvf /backup/$host/nds/$1 -a $admin -p $pswd | tee -a $log;;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no.";;
    esac
  done
fi

# E-mail results
if [ -n "$email" ]; then
  mail -s "NDS Backup log for $host" $email < $log
fi

echo "-------------------------------------------------------------------------------------------------" >> $log

# Finished
exit 1

