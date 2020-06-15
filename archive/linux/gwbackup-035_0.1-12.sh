#!/bin/bash
REL=0.1-12
SID=035
##############################################################################
#
#    gwbackup.sh - create a quick and easy backup to a remote server of the
#		   local GroupWise system
#    Copyright (C) 2012  David Robb 
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#
##############################################################################
# Date Created: Thu Aug 02 10:28:19 2012 
# Last updated: Wed May 27 14:27:21 2015 
# Crontab command: 
# Supporting file: None
# Additional notes: 
##############################################################################
# Declare varilables
TODAY=$(date +'%d-%m-%Y')
HOST=$(hostname)
ID=$(whoami)
DONAME=devdo
PONAME=devpo

# Custom Variables
BKSRV=dev-oes2sp3
BKIP=192.168.2.201
USER=admin.dev
PW=nashira!=000
DONAME=devdo
PONAME=devpo
REPDIR=/root/reports
REPNAME=GW_Backup_Report
GWCFG=/etc/opt/novell/groupwise/gwha.conf
GWSHR=/opt/novell/groupwise/agents/share
GWBIN=/opt/novell/groupwise/agents/bin
GWMTA="/media/nss/MAIL/dev-do"
GWPOA="/media/MAIL/dev-po"
EMAIL=root
HT=$HOST-$TODAY
REPORT=$REPDIR/$REPNAME-from-$HT.txt
INCDIR=/root/bin

# Functions
addspace() { echo "" >>$REPORT 
}

# Delete old report
if [ -e $REPDIR/$REPNAME*.txt ]; then
  /bin/rm $REPDIR/$REPNAME*.txt
fi

# Create new report and set date timestamp
addspace
echo "--[ GroupWise Backup Report v${REL} ]------------------------------------------------" >> $REPORT
echo "--[ Report started at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]----------------------------------" >> $REPORT
addspace

# Check if gwha is running and shut it down for the backup
PROCGWHA=$(ps -ef | grep -v grep | grep -cw xinetd)
if [ $PROCGWHA -eq 1 ]; then
  rcxinetd stop
else
  echo "$HOST $(date +'%b %d %T') - gwha (xinetd) is not configured to run on this server. Continuing backup process." >> $REPORT
fi

echo "$HOST $(date +'%b %d %T') - gwha has been shutdown prior to backup so the agents don't restart during backup." >> $REPORT

# Mount the backup location to the local server
ncpmount -S $BKSRV -A $BKIP -U $USER -P $PW -V BACKUP -m /media/backup
echo "$HOST $(date +'%b %d %T') - Remote backup location has been mounted to the local server." >> $REPORT

# Shutdown GroupWise agents to do an uniterrupted backup
rcgrpwise stop
# Check to see if the MTA is stopped
PROCGW1=$(ps -ef | grep -v grep | grep -cw gwmta)

# Check to see if the POA is stopped
PROCGW2=$(ps -ef | grep -v grep | grep -cw gwpoa)

if [ $PROCGW1 -eq 0 ]; then
  echo "$HOST $(date +'%b %d %T') - GroupWise MTA Agent shutdown prior to backup to ensure a full backup." >> $REPORT
else
  echo "$HOST $(date +'%b %d %T') - GroupWise MTA Agent is not shutdown. Backup may take longer." >> $REPORT
fi

if [ $PROCGW2 -eq 0 ]; then
  echo "$HOST $(date +'%b %d %T') - GroupWise POA Agent shutdown prior to backup to ensure a full backup." >> $REPORT
else
  echo "$HOST $(date +'%b %d %T') - GroupWise POA Agent is not shutdown. Backup may take longer." >> $REPORT
fi

# Backup the MTA folders and files
$GWBIN/dbcopy -v $GWMTA /media/backup/$DONAME/
echo "$HOST $(date +'%b %d %T') - The Domain has been backed up to the backup drive." >> $REPORT
echo "$HOST $(date +'%b %d %T') - Please see the log mta-backup$(date +'%m%d').log for details and/or errors." >> $REPORT

# Backup the POA folders and files
$GWBIN/dbcopy -v $GWPOA /media/backup/$PONAME/
echo "$HOST $(date +'%b %d %T') - The Post Office has been backed up to the backup drive." >> $REPORT
echo "$HOST $(date +'%b %d %T') - Please see the log poa-backup$(date +'%m%d').log for details and/or errors." >> $REPORT

# Restart the GroupWise agents after backup
rcgrpwise start
sleep 30
PROCGW3=$(ps -ef | grep -v grep | grep -cw gwmta)
if [ $PROCGW3 -eq 1 ]; then
  echo "$HOST $(date +'%b %d %T') - GroupWise MTA Agent has been restarted after the backup." >> $REPORT
else
  echo "$HOST $(date +'%b %d %T') - GroupWise MTA Agent did not restart correctly, please investigate." >> $REPORT
fi

PROCGW4=$(ps -ef | grep -v grep | grep -cw gwpoa)
if [ $PROCGW4 -eq 1 ]; then
  echo "$HOST $(date +'%b %d %T') - GroupWise POA Agent has been restarted after the backup." >> $REPORT
else
  echo "$HOST $(date +'%b %d %T') - GroupWise POA Agent did not restart correctly, please investigate." >> $REPORT
fi

echo "$HOST $(date +'%b %d %T') - Backup of all GroupWise files and folders is complete, and the GroupWise Agents have been restarted." >> $REPORT

# Restart gwha after the backup
rcxinetd start
sleep 10
PROCGWHA1=$(ps -ef | grep -v grep | grep -cw xinetd)
if [ $PROCGWHA1 -eq 1 ]; then
  echo "$HOST $(date +'%b %d %T') - gwha (xinetd) has been restarted. GroupWise agents will automatically restart if they shutdown." >> $REPORT
else
  echo "$HOST $(date +'%b %d %T') - gwha (xinetd) did not restart correctly, please investigate." >> $REPORT
fi

# TimeStamp the userDB's with the backup time
$GWBIN/gwtmstmp --postpath $GWPOA --set --backup
echo "$HOST $(date +'%b %d %T') - Setting a new date/timestamp on all user databases indicating last backup time." >> $REPORT

# Copy the dbcopy logs to /root/reports
cp /media/backup/$DONAME/*gwbk.* /root/reports/mta-backup$(date +'%m%d').log
cp /media/backup/$PONAME/*gwbk.* /root/reports/poa-backup$(date +'%m%d').log

# Unmount the backup location
ncpumount /media/backup
echo "$HOST $(date +'%b %d %T') - Remote backup location has been unmounted from the local server." >> $REPORT

# Close report and set date-timestamp
addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]---------------------------------" >> $REPORT
addspace

# Variables for the zip file
LOG1="$REPDIR/mta-backup$(date +"%m%d").log"
LOG2="$REPDIR/poa-backup$(date +"%m%d").log"
REPORTZIP=gw_backup_report-$(date +'%m%d%Y').zip

# Create a zip archive of the report and the two logs
zip $REPDIR/$REPORTZIP $REPORT $LOG1 $LOG2

# E-mail results to gwadmin
if [ -n "$EMAIL" ]; then
  echo -e "Please find attached the GroupWise Backup Report including the MTA, and POA dbcopy log. Please review the files for errors and perform the necessary corrective action. These files should be stored on the network for historical reference." | mail -s "$HOST GroupWise Backup Report" -a $REPDIR/$REPORTZIP $EMAIL
fi

# finished
exit 1

