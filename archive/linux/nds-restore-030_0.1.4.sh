#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-restore.sh
# 
#         USAGE: ./nds-restore.sh 
# 
#   DESCRIPTION: Restore eDirectory objects to an OES server
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
#       CREATED: Mon Sep 16 2013 12:52
#  LAST UPDATED: Sun Jun 19 2016 13:21
#      REVISION: 3
#     SCRIPT ID: 030
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=030                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
ndsconf=/etc/opt/novell/eDirectory/conf         # Path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin               # Path to nds binaries
fn=$host$df                                     # File name
admin=                                          # Administrators account name FQN
pswd=                                           # Administrator's password
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/nds-restore.log'                  # logging (if required)

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

