#!/bin/bash - 
#===============================================================================
#
#          FILE: s-backup.sh
# 
#         USAGE: ./s-backup.sh 
# 
#   DESCRIPTION: Backup the local bash script directories to a remote server
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
#       CREATED: Fri Jun 28 2013 13:21
#  LAST UPDATED: Tue Jun 14 2016 14:23
#      REVISION: 8
#     SCRIPT ID: 002
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.9
sid=002                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
rhost=excs-bkup.excession.org                   # host name of remote server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/s-backup.log'                     # logging (if required)

function initlog() { 
  if [ -e $log ]; then
    echo "log file exists" > /dev/null
  else
    touch $log
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function logit() { 
  echo $ts $host: $* >> ${log}
}

initlog
logit "Commencing backup of scripts on $host to $rhost"

rsync -r -a -v -e "ssh -l root" --delete /rnd/scripts rnd1:/ark | tee -a $log
rsync -r -a -v -e "ssh -l root" --delete /rnd/docs rnd1:/ark | tee -a $log
rsync -r -a -v -e "ssh -l root" --delete /rnd/apps rnd1:/ark | tee -a $log

logit "Backup complete"

ssh rnd1 "tree -s -f /ark" > /tmp/rnd1listing
ssh rnd3 "tree -s -f /rnd" > /tmp/rnd3listing
L1=$(awk 'END{print}' /tmp/rnd1listing > /tmp/rnd1total && cat /tmp/rnd1total | md5sum | cut -f1 -d " ") 
L3=$(awk 'END{print}' /tmp/rnd1listing > /tmp/rnd3total && cat /tmp/rnd3total | md5sum | cut -f1 -d " ")   

if [ $L1 = $L3 ]; then
  echo -e "The Research and Development repository was successfully backed from $host to $dhost." | mail -s "Repository Backup Completed Successfully" $email
else
  echo -e "The Reseach and Development repository was backed up, but there are differences between the source and destination folders. Please investigate." | mail -s "Repository Backup Incomplete" $email
fi

echo "--------------------------------------------------------" >> $log

# Cleanup files
sleep 2
rm -f /tmp/rnd*

exit

