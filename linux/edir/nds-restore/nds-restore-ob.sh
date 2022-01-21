#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-restore-ob.sh
# 
#         USAGE: ./nds-restore-ob.sh 
# 
#   DESCRIPTION: Restore a single eDirectory object to an OES server
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
#       CREATED: Mon Sep 16 2013 14:46
#  LAST UPDATED: Tue Mar 13 2018 11:08
#       VERSION: 0.1.4
#     SCRIPT ID: 031
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=eDirectory-restore                         # email sender
email=root                                       # email recipient(s)
log='/var/log/nds-restore-ob.log'                # log name and location (if required)
ndsbin=/opt/novell/eDirectory/bin                # path to nds binaries
admin=                                           # administrators account name FQN
pswd=                                            # administrators password
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

# help message
function helpme() { 
  echo "The correct command line syntax is: "
  echo "./nds-restore <hostname_day-of-week> <edirectory_object>"
  echo "for example ./nds-restore.sh acpic-s779Thursday CN=000212363.OU=ECS.O=CEN"
  exit 1
}

initlog

# Restore single eDirectory object
if [ $# -lt 2 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  $ndsbin/ndsbackup xvfw /backup/"$host"/nds/"$1" -a "$admin" -p "$pswd" "$2" | tee -a "$log"
fi

# mail message
function mail_body1() { 
echo -e "An object level restore has been performed on $host. Please review the attached log for errors."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NDS Backup log for $host" -r $mfrom $email -a $log
fi

# Finished
exit 0
