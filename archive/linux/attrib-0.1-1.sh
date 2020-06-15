#!/bin/bash
REL=0.1-1
##############################################################################
#
#    attrib.sh - Script to set folder attributes on NSS
#    Copyright (C) 2014  David Robb
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
# Date Created: Mon Dec 15 10:55:14 2014 
# Last updated: Mon Dec 15 11:28:01 2014 
# Crontab command: 
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
NSSSBIN=/opt/novell/nss/sbin
NSSBASE=/media/nss
LOG=/var/log/attrib.log

function initlog() { 
  if [ -e /var/log/attrib.log ]
    then
      echo "log file exists" > /dev/null
    else
      echo "Logging started at ${TS}" > ${LOG}
      echo "All actions are being performed by the user: ${USER}" >> ${LOG}
      echo " " >> ${LOG}
  fi
}

function logit() { 
  echo $TS $HOST $* >> ${LOG}
}

initlog

function helpme() { 
  echo "The correct command line syntax is ./attrib.sh VOL_NAME"
  echo "for example ./attrib.sh NCR_DATA1_PR"
  logit "Command execution failed"
  exit 1
}

# Generate a list of the top level folders to work with
ls -l $NSSBASE/$1 | grep "^d" | awk '{print $NF}' > /tmp/dir_list.txt
DIRS=$(cat /tmp/dir_list.txt)
logit "The directories to be modified are: $DIRS"

# Lets modify the attributes now
if [ $# -lt 1 ] 
  then
    echo "There are not enough arguments on the command line." > /dev/stderr
    helpme
  else
    for d in $DIRS
      do
        $NSSSBIN/attrib -s=di,ri | tee -a $LOG
      done
fi

echo "-----------------------------------------------------------------------------------------------------------" >> $LOG

exit
