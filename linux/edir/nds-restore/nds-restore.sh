#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-restore.sh
# 
#         USAGE: ./nds-restore.sh 
# 
#   DESCRIPTION: Restore eDirectory objects to an OES server
#
#                Copyright (c) 2018, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Sep 16 2013 12:52
#  LAST UPDATED: Tue Mar 13 2018 11:03
#       VERSION: 0.1.5
#     SCRIPT ID: 030
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=eDirectory-restore                         # email sender
email=root                                       # email recipient(s)
log='/var/log/nds-restore.log'                   # log name and location (if required)
ndsbin=/opt/novell/eDirectory/bin                # path to nds binaries
# fn=$host$df                                      # file name
admin=                                           # administrators account name FQN
pswd=                                            # administrator's password
#===============================================================================

# initialize logging
function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists"
  else
    echo "Logging started at ${ts}" > "$log"
    echo "All actions are being performed by the user: ${user}" >> "$log"
    echo " " >> "$log"
  fi
}

# warning message
function warning() {
	echo "--[ WARNING ]--------------------------------------------------------"
	echo "This script will restore the entire eDirectory tree."
	echo "This should only be done if the tree has been damaged beyond repair,"
	echo "and all objects have been lost."
	echo "If you need to restore an individual object or a sub container please"
	echo "refer to the man pages for ndsbackup (man ndsbackup)."
	echo "====================================================================="
}

# help message
function helpme() { 
	echo "The correct command line syntax is ./nds-restore <hostname_day-of-week>"
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
    read -r -p "Do you wish to continue with the nds restore? (y/n) " YN
    echo "==============================================="
    case $YN in
    [Yy]* ) $ndsbin/ndsbackup xvf /backup/"$host"/nds/"$1" -a "$admin" -p "$pswd" | tee -a "$log";;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no.";;
    esac
  done
fi
# mail message
function mail_body1() { 
echo -e "A nds restore operation has completed on $host. Please review the attached logs to see if there were errors encountered."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NDS Restore log for $host" -r $mfrom $email -a $log
fi

# Finished
exit 1

