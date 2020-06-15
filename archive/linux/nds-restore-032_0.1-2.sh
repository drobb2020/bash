#!/bin/bash
REL=0.1-2
SID=032
##############################################################################
#
#    nds-restore.sh - Backup eDirectory objects from an OES Server
#    Copyright (C) 2013  David Robb
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
# Date Created: Mon Sep 16 12:52:52 2013 
# Last updated: Wed May 27 14:02:05 2015 
# Suggested Crontab command: Not recommended, script should be run manually
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DS=$(date +%a)
DF=$(date +%A)
TS=$(date +"%b %d %T")
HOST=$(hostname)
NDSCONF=/etc/opt/novell/eDirectory/conf/nds.conf
NDSBIN=/opt/novell/eDirectory/bin
FN=$HOST$DF
ADMIN="cn=admin.o=test"
PW=nashira!=000
EMAIL=root
USER=$(whoami)
LOG=/var/log/ndsbackup/ndsrestore-$DS.log

function initlog() { 
  if [ -e /var/log/ndsbackup/ndsrestore.log ]; then
    echo "log file exists"
  else
    echo "Logging started at ${TS}" > ${LOG}
    echo "All actions are being performed by the user: ${USER}" >> ${LOG}
    echo " " >> ${LOG}
  fi
}

function warning() {
	echo "--[ Warning ]--------------------------------------------------------"
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
    [Yy]* ) $NDSBIN/ndsbackup xvf /backup/$HOST/nds/$1 -a $ADMIN -p $PW | tee -a $LOG;;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no.";;
    esac
  done
fi

# E-mail results
if [ -n "$EMAIL" ]; then
  mail -s "NDS Backup log for $HOST" $EMAIL < $LOG
fi

echo "-------------------------------------------------------------------------------------------------" >> $LOG

# Finished
exit 1

