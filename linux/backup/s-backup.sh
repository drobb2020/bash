#!/bin/bash - 
#===============================================================================
#
#          FILE: s-backup.sh
# 
#         USAGE: ./s-backup.sh 
# 
#   DESCRIPTION: Backup the local bash script directories to a remote server
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
#       CREATED: Fri Jun 28 2013 13:21
#  LAST UPDATED: Thu Mar 08 2018 09:39
#       VERSION: 0.1.10
#     SCRIPT ID: 002
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
rhost=excs-bkup.excession.org                    # host name of remote server
user=$(whoami)                                   # who is running the script
mfrom=script-backup                              # email sender
email=root                                       # email recipient(s)
log='/var/log/s-backup.log'                      # log name and location (if required)
#===============================================================================
function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch "$log"
    echo "Logging started at ${ts}";
    echo "All actions are being performed by the user: ${user}";
    echo " " >> "$log"
  fi
}

function logit() { 
  echo "$ts" "$host": "$@" >> "$log"
}

initlog
logit "Commencing backup of scripts on $host to $rhost"

rsync -rave "ssh -l root" --delete /rnd/scripts rnd1:/ark | tee -a "$log"
rsync -rave "ssh -l root" --delete /rnd/docs rnd1:/ark | tee -a "$log"
rsync -rave "ssh -l root" --delete /rnd/apps rnd1:/ark | tee -a "$log"

logit "Backup complete"

ssh rnd1 "tree -s -f /ark" > /tmp/rnd1listing
ssh rnd3 "tree -s -f /rnd" > /tmp/rnd3listing
L1=$(awk 'END{print}' /tmp/rnd1listing > /tmp/rnd1total && cat /tmp/rnd1total | md5sum | cut -f1 -d " ") 
L3=$(awk 'END{print}' /tmp/rnd1listing > /tmp/rnd3total && cat /tmp/rnd3total | md5sum | cut -f1 -d " ")   

if [ "$L1" = "$L3" ]; then
  echo -e "The Research and Development repository was successfully backed from $host to $rhost." | mail -s "Repository Backup Completed Successfully" -r $mfrom $email
else
  echo -e "The Research and Development repository was backed up, but there are differences between the source and destination folders. Please investigate." | mail -s "Repository Backup Incomplete" -r $mfrom $email
fi

echo "--------------------------------------------------------" >> "$log"

# Cleanup files
sleep 2
rm -f /tmp/rnd*

exit 0
