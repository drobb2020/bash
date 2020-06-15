#!/bin/bash
REL=0.1-1
SID=
##############################################################################
#
#    restartnamcd.sh - SSC Restart script for namcd daemon
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
#
##############################################################################
# Date Created: Wed Jun 10 09:18:17 2015 
# Last updated: Thu Jun 11 10:47:50 2015 
# Crontab command: */10 * * * * /root/bin/restartnamcd.sh
# Supporting file: None
# Additional notes: 
##############################################################################
#Variables
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/namcdrestart.log"

function initlog() { 
if [ -e /var/log/namcdrestart.log ]; then
  echo "log file exists" > /dev/null
else
  touch /var/log/namcdrestart.log
  echo "Logging started at ${TS}" > ${LOG}
  echo "All actions are being performed by the user: ${USER}" >> ${LOG}
  echo " " >> ${LOG}
fi
}

function logit() { 
  echo -e $TS $HOST: $* >> ${LOG}
}

function restartlum() { 
  logit "namcd is dead or missing critical accounts, a restart is necessary on $HOST."
  logit "Restart of namcd has been issued by cron job on $HOST."
  /etc/init.d/namcd stop | tee -a $LOG
  /etc/init.d/nscd restart | tee -a $LOG
  /etc/init.d/namcd start | tee -a $LOG
  logit "Restart command issued."
}

function lumIcheck() {
  /etc/init.d/namcd status &>/dev/null
  namcdReturnCodeI=$?
}

function lumAcheck() { 
  /etc/init.d/namcd status &>/dev/null
  namcdReturnCodeA=$?
  if [ $namcdReturnCodeA = 0 ]; then
    logit "namcd was successfully restarted on $HOST."
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n $EMAIL ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $HOST. Please login as casadmin, and attempt a manual restart. Check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
}

function lumrunning() { 
  logit "namcd is running fine on $HOST, no need to restart."
}

initlog
logit "v$REL SSC namcd restart script"
logit "=============================="
logit "------------------------------"
logit "NAMCD daemon Control"
logit "------------------------------"

# Check to see if critical accounts are in the cache
CA1=$(/usr/bin/id tsmadm | awk '{ print $1 }')
CA2=$(/usr/bin/id a00153775 | awk '{ print $1 }')
CA3=$(/usr/bin/id a00155885 | awk '{ print $1 }')
CA4=$(/usr/bin/id a00162341 | awk '{ print $1 }')
CA5=$(/usr/bin/id a00212363 | awk '{ print $1 }')

# write the values to files temporarily
echo $CA1 > /tmp/ca1.tmp.$$ | tee -a $LOG
echo $CA2 > /tmp/ca2.tmp.$$ | tee -a $LOG
echo $CA3 > /tmp/ca3.tmp.$$ | tee -a $LOG
echo $CA4 > /tmp/ca4.tmp.$$ | tee -a $LOG
echo $CA5 > /tmp/ca5.tmp.$$ | tee -a $LOG

LUM1=$(cat /tmp/ca1.tmp.$$ | cut -f 1 -d '=')
LUM2=$(cat /tmp/ca2.tmp.$$ | cut -f 1 -d '=')
LUM3=$(cat /tmp/ca3.tmp.$$ | cut -f 1 -d '=')
LUM4=$(cat /tmp/ca4.tmp.$$ | cut -f 1 -d '=')
LUM5=$(cat /tmp/ca5.tmp.$$ | cut -f 1 -d '=')

# If there are is no uid in each variable then LUM is not working
if [ -z "$LUM1" -o "$LUM2" -o "$LUM3" -o "$LUM4" -o "$LUM5" ]; then
  logit "Critical accounts seem to be missing from LUM."
  restartlum
else
  lumrunning
fi

# Check current status of daemon
lumIcheck

if [ $namcdReturnCodeI = 0 ]; then
  logit "namcd is running fine, no need to restart."
else
  restartlum
  lumAcheck
fi

logit "------------------------------"

# Clean up
rm -f /tmp/ca*.tmp.$$

exit 1

