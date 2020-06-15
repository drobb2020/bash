#!/bin/bash
REL=0.1-1
SID=041
##############################################################################
#
#    adjNcpThreads.sh - Sript to adjust NCP threads
#    Copyright (C) 2015  David Robb
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
#       Jacques Guillemette (jacques.guillemette@ssc-spc.gc.ca)
#
##############################################################################
# Date Created: Thu Mar 19 09:39:58 2015 
# Last updated: Wed May 27 15:00:55 2015 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog.
DIALOG=${DIALOG=dialog}
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/ncpthreads.log"

# Check to see if user is root
if [ $USER != "root" ]; then
  echo "You must be root to run this script, but you are: $USER."
  echo "The script will now exit. Please sudo to root and try again."
  sleep 3
  exit 1
fi

# Lets log everything we do
function initlog() { 
  if [ -e /var/log/ncpthreads.log ]; then
    echo "log file exists" > /dev/null
  else
    touch /var/log/ncpthreads.log
    echo "Logging started at ${TS}" > ${LOG}
    echo "All actions are being performed by the user: ${USER}" >> ${LOG}
    echo " " >> ${LOG}
  fi
}

# Date and timestamp each entry
function logit() { 
  echo -e $TS $HOST: $* >> ${LOG}
}

# Initialize the log
initlog

# Log header
logit "v$REL SSC OES11 SP2 post configuration NCP thread adjustment"
logit "============================================================"
logit " "

# Current NCP Thread Settings
logit "-------------------------------------"
logit "Current Novell Core Protocol Settings"
logit "-------------------------------------"
/sbin/ncpcon threads >> $LOG
clear

# NCP Configuration Changes
logit "-------------------------------------"
logit "Novell Core Protocol Settings Change"
logit "-------------------------------------"
# No error checking required on these settings.
/sbin/ncpcon set CONCURRENT_ASYNC_REQUESTS=128
/sbin/ncpcon set ADDITIONAL_SSG_THREADS=75
echo "NCP server settings have been modified"
logit "The following NCP settings were made:\n\t\t\t\tCONCURRENT_ASYNC_REQUESTS set to 128.\n\t\t\t\tADDITIONAL_SSG_THREAD set to 75"
clear

# Post NCP Thread Settings
logit "------------------------------------"
logit "Post Novell Core Protocol Settings"
logit "------------------------------------"
/sbin/ncpcon threads >> $LOG
clear

# Finished
exit 1

