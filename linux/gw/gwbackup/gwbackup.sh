#!/bin/bash - 
#===============================================================================
#
#          FILE: gwbackup.sh
# 
#         USAGE: ./gwbackup.sh 
# 
#   DESCRIPTION: Create a backup of a GroupWise system to a remote server
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
#       CREATED: Thu Aug 02 2012 10:28
#  LAST UPDATED: Tue Mar 13 2018 13:50
#       VERSION: 0.1.15
#     SCRIPT ID: 033
# SSC SCRIPT ID: 00
#===============================================================================

ts=$(date +"%b %d %T")               # general date|time stamp
host=$(hostname)                     # hostname of the local server
email=root                           # email recipient(s)
today=$(date +'%d-%m-%Y')            # today datestamp
doname=                              # name of GW Domain
poname=                              # name of Gw Post Office
bkupsrv=                             # name of backup server
bkupip=                              # IP Address of backup server
admin=                               # administrators account name dotted format
pswd=                                # administrator's password
repdir=/root/reports                 # directory to write reports to
repname=GW_Backup_Report             # report name
gwbin=/opt/novell/groupwise/agents/bin # GW binaries
gwmta="/media/nss/MAIL/dev-do"       # path to GW Domain directory
gwpoa="/media/MAIL/dev-po"           # path to GW Post Office directory
ht=$host-$today                 # hostname and date for report name generation
report=$repdir/$repname-from-$ht.txt # report name
#===============================================================================

# Functions
addspace() { 
  echo "" >> "$report"
}

# Delete old report
if [ -e "$report" ]; then
  /bin/rm "$report"
fi

# Create new report and set date timestamp
addspace
echo "--[ GroupWise Backup Report ]--------------------------------------------------------" >> "$report"
echo "--[ Report started at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]----------------------------------" >> "$report"
addspace

# Check if gwha is running and shut it down for the backup
PROCGWHA=$(pgrep -c xinetd | grep -v grep)
if [ "$PROCGWHA" -eq 1 ]; then
  rcxinetd stop
else
  echo "$host $ts - gwha (xinetd) is not configured to run on this server. Continuing backup process." >> "$report"
fi

echo "$host $ts - gwha has been shutdown prior to backup so the agents don't restart during backup." >> "$report"

# Mount the backup location to the local server
ncpmount -S "$bkupsrv" -A "$bkupip" -U "$admin" -P "$pswd" -V BACKUP -m /media/backup
echo "$host $ts - Remote backup location has been mounted to the local server." >> "$report"

# Shutdown GroupWise agents to do an uninterrupted backup
/etc/init.d/grpwise stop
# Check to see if the MTA is stopped
PROCGW1=$(pgrep -c gwmta | grep -v grep)

# Check to see if the POA is stopped
PROCGW2=$(pgrep -c gwpoa | grep -v grep)

if [ "$PROCGW1" -eq 0 ]; then
  echo "$host $ts - GroupWise MTA Agent shutdown prior to backup to ensure a full backup." >> "$report"
else
  echo "$host $ts - GroupWise MTA Agent is not shutdown. Backup may take longer." >> "$report"
fi

if [ "$PROCGW2" -eq 0 ]; then
  echo "$host $ts - GroupWise POA Agent shutdown prior to backup to ensure a full backup." >> "$report"
else
  echo "$host $ts - GroupWise POA Agent is not shutdown. Backup may take longer." >> "$report"
fi

# Backup the MTA folders and files
$gwbin/dbcopy -v $gwmta /media/backup/"$doname"/
echo "$host $ts - The Domain has been backed up to the backup drive." >> "$report"
echo "$host $ts - Please see the log mta-backup$(date +'%m%d').log for details and/or errors." >> "$report"

# Backup the POA folders and files
$gwbin/dbcopy -v $gwpoa /media/backup/"$poname"/
echo "$host $ts - The Post Office has been backed up to the backup drive." >> "$report"
echo "$host $ts - Please see the log poa-backup$(date +'%m%d').log for details and/or errors." >> "$report"

# Restart the GroupWise agents after backup
/etc/init.d/grpwise start
sleep 30

PROCGW3=$(pgrep -c gwmta | grep -v grep)
if [ "$PROCGW3" -eq 1 ]; then
  echo "$host $ts - GroupWise MTA Agent has been restarted after the backup." >> "$report"
else
  echo "$host $ts - GroupWise MTA Agent did not restart correctly, please investigate." >> "$report"
fi

PROCGW4=$(pgrep -c gwpoa | grep -v grep)
if [ "$PROCGW4" -eq 1 ]; then
  echo "$host $ts - GroupWise POA Agent has been restarted after the backup." >> "$report"
else
  echo "$host $ts - GroupWise POA Agent did not restart correctly, please investigate." >> "$report"
fi

echo "$host $ts - Backup of all GroupWise files and folders is complete, and the GroupWise Agents have been restarted." >> "$report"

# Restart gwha after the backup
rcxinetd start
sleep 10

PROCGWHA1=$(pgrep -c xinetd | grep -v grep)
if [ "$PROCGWHA1" -eq 1 ]; then
  echo "$host $ts - gwha (xinetd) has been restarted. GroupWise agents will automatically restart if they shutdown." >> "$report"
else
  echo "$host $ts - gwha (xinetd) did not restart correctly, please investigate." >> "$report"
fi

# TimeStamp the userDB's with the backup time
$gwbin/gwtmstmp --postpath $gwpoa --set --backup
echo "$host $ts - Setting a new date/timestamp on all user databases indicating last backup time." >> "$report"

# Copy the dbcopy logs to /root/reports
cp /media/backup/"$doname"/*gwbk.* /root/reports/mta-backup"$(date +'%m%d')".log
cp /media/backup/"$poname"/*gwbk.* /root/reports/poa-backup"$(date +'%m%d')".log

# Unmount the backup location
ncpumount /media/backup
echo "$host $ts - Remote backup location has been unmounted from the local server." >> "$report"

# Close report and set date-timestamp
addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]---------------------------------" >> "$report"
addspace

# Variables for the zip file
log1="$repdir/mta-backup$(date +"%m%d").log"
log2="$repdir/poa-backup$(date +"%m%d").log"
reportzip=gw_backup_report-$(date +'%m%d%Y').zip

# Create a zip archive of the report and the two logs
zip $repdir/"$reportzip" "$report" "$log1" "$log2"

# E-mail results to gwadmin
if [ -n "$email" ]; then
  echo -e "Please find attached the GroupWise Backup Report including the MTA, and POA dbcopy log. Please review the files for errors and perform the necessary corrective action. These files should be stored on the network for historical reference." | mail -s "$host GroupWise Backup Report" -a "$repdir"/"$reportzip" "$email"
fi

# finished
exit 0
