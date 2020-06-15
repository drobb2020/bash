#!/bin/bash
REL=0.1-9
SID=009
##############################################################################
#
#    ndsd-mon.sh - Monitor and restart nds if it crashes
#    Copyright (C) 2015  David Robb
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
# Date Created: Thu Apr 12 14:48:47 2012 
# Last updated: Wed May 27 11:33:59 2015 
# Crontab command: */5 * * * * /root/bin/ndsd-mon.sh
# Supporting file: None
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/ndsdmon.log"

function initlog() { 
   if [ -e /var/log/ndsdmon.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/ndsdmon.log
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo $TS $HOST: $* >> ${LOG}
}

initlog

# Check for the current status of the eDirectory daemon ndsd
 /usr/sbin/rcndsd status &>/dev/null
 ndsdReturnCode=$?

logit "Return Code for NDSD: $ndsdReturnCode"

# Check for the current status of the Linux User Management daemon namcd
 /usr/sbin/rcnamcd status &>/dev/null
 namcdReturnCode=$?

logit "Return Code for NAMCD: $namcdReturnCode"

# Check for the current status of the DFS daemon novell-dfs
/sbin/rcnovell-dfs status &>/dev/null
dfsReturnCode=$?

logit "Return Code for novell-dfs: $dfsReturnCode"

# Act if ndsd is down
if [ $ndsdReturnCode == "0" ]; then
  logit "NDSD service is running"
else
  if [ -n $EMAIL ]; then
    echo -e "eDirectory is not running on: $HOST" | mail -s "eDirectory is DOWN on $HOST" $EMAIL
  fi
  logit "eDirectory is not running on $HOST, attempting restart now"
  /usr/sbin/rcndsd restart
  logit "NDSD restart attempt complete"
  # Ensure NDSD is running
  /usr/sbin/rcndsd status &>/dev/null
  ndsdReturnCode2=$?
  if [ $ndsdReturnCode2 == 0 ]; then
    logit "Confirmed ndsd daemon successfully restarted."
  else
    logit "For some reason the last restart of ndsd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n $EMAIL ]; then
      echo -e "The restart of the ndsd daemon has failed and ndsd may not be running on $HOST. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors." | mail -s "ATTENTION: ndsd restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
  /usr/sbin/rcnamcd restart
  logit "namcd restarted after ndsd restart"
  /usr/sbin/rcnamcd status &>/dev/null
  namcdReturnCode2=$?
  if [ $namcdReturnCode2 == 0 ]; then
    logit "ndsd daemon successfully restarted."
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n $EMAIL ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $HOST. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
fi

# Act if namcd is down
if [ $namcdReturnCode == "0" ]; then
  logit "NAMCD service is running"
else
  if [ -n $EMAIL ]; then
    echo -e "namcd, Linux User Management, is not running on: $HOST" | mail -s "namcd is DOWN" $EMAIL
  fi
  logit "namcd (LUM) is not running on $HOST, attempting restart now"
  /usr/sbin/rcnamcd restart
  logit "namcd restart attempt complete"
  /usr/sbin/rcndsd status &>/dev/null
  ndsdReturnCode3=$?
  if [ $ndsdReturnCode3 == 0 ]; then
    logit "ndsd daemon successfully restarted."
  else
    logit "For some reason the last restart of ndsd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n $EMAIL ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $HOST. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
fi

# Act if novell-dfs is down
if [ $dfsReturnCode == "0" ]; then
  logit "novell-dfs service is running"
else
  if [ -n $EMAIL ]; then
    echo -e "novell-dfs is not running on: $HOST" | mail -s "novell-dfs is DOWN" $EMAIL
  fi
  logit "novell-dfs is not running on $HOST, attempting restart now."
  /usr/sbin/rcnovell-dfs restart
  logit "novell-dfs restart attempt complete."
  /usr/sbin/rcndsd status &>/dev/null
  dfsReturnCode2=$?
  if [ $dfsReturnCode2 == 0 ]; then
    logit "ndsd daemon successfully restarted."
  else
    logit "For some reason the last restart of ndsd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n $EMAIL ]; then
      echo -e "A regular check of the status of the novell-dfs daemon showed it was not running. However, The restart of the novell-dfs daemon has failed and novell-dfs may not be running on $HOST. Please attempt a manual restart, and check the log (/var/log/messages) for errors." | mail -s "ATTENTION: novell-dfs restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
fi

echo "--------------------------------------------------------" >> $LOG

# Finished
exit 1

