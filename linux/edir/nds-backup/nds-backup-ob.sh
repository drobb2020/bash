#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-backup-ob.sh
# 
#         USAGE: ./nds-backup-ob.sh 
# 
#   DESCRIPTION: Backup selected eDirectory object or a container from an OES Server
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
#       CREATED: Tue Sep 17 2013 08:12
#  LAST UPDATED: Tue Mar 13 2018 10:43
#       VERSION: 0.1.6
#     SCRIPT ID: 029
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=eDirectory-backup                          # email sender
email=root                                       # email recipient(s)
log='/var/log/nds-backup-ob.log'                 # log name and location (if required)
ndsbin=/opt/novell/eDirectory/bin                # path to eDirectory binaries
fn=$host-$1-$df                                  # file name
admin=                                           # administrator (FDN) account
pswd=                                            # administrator's password
#===============================================================================
# Create the necessary folders
if [ -d /backup/nds ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/"$host"/nds
fi

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
	echo "--[ Help ]---------------------------------"
	echo "The correct command line syntax is: "
	echo "./nds-backup-ob.sh <edirectory_object>"
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
  $ndsbin/ndsbackup cvf /backup/"$host"/nds/"$fn" -a "$admin" -p "$pswd" "$1" | tee -a "$log"
fi

# mail message body
function mail_body1() { 
echo -e "An object level backup has been done on $host. The results of the backup are attached."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NDS Backup log for $host" -r "$mfrom" "$email" -a "$log"
fi

# Finished
exit 0
