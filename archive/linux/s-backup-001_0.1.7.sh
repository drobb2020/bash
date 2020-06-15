#!/bin/bash
REL=0.1-7
SID=001
##############################################################################
#
#    s-backup.sh - Backup the local script directory to a remote server
#    Copyright (C) 2013  David Robb
#
##############################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
# Date Created: Fri Jun 28 13:21:03 2013 
# Last updated: Wed May 27 09:33:57 2015 
# Crontab command: Suggest the script be run manually
# Supporting file: None
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/rnd-backups.log"

function initlog() { 
   if [ -e /var/log/rnd-backups.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/rnd-backups.log
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo $TS $HOST: $* >> ${LOG}
}

initlog
logit "Commencing backup of scripts on $HOST to rnd-oes2sp3"

rsync -r -a -v -e "ssh -l root" --delete /rnd/scripts rnd1:/ark | tee -a $LOG
rsync -r -a -v -e "ssh -l root" --delete /rnd/docs rnd1:/ark | tee -a $LOG
rsync -r -a -v -e "ssh -l root" --delete /rnd/apps rnd1:/ark | tee -a $LOG

logit "Backup complete"

ssh rnd1 "tree -s -f /ark" > /tmp/rnd1listing
ssh rnd3 "tree -s -f /rnd" > /tmp/rnd3listing
L1=$(awk 'END{print}' /tmp/rnd1listing > /tmp/rnd1total && cat /tmp/rnd1total | md5sum | cut -f1 -d " ") 
L3=$(awk 'END{print}' /tmp/rnd1listing > /tmp/rnd3total && cat /tmp/rnd3total | md5sum | cut -f1 -d " ")   

if [ $L1 = $L3 ]
    then
	echo -e "The Research and Development repository was successfully backed from $HOST to $DHOST." | mail -s "Repository Backup Completed Successfully" $EMAIL
    else
	echo -e "The Reseach and Development repository was backed up, but there are differences between the source and destination folders. Please investigate." | mail -s "Repository Backup Incomplete" $EMAIL
fi

echo "--------------------------------------------------------" >> $LOG

# Cleanup files
sleep 2
rm -f /tmp/rnd*

exit

