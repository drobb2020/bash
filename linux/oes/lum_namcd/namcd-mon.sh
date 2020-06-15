#!/bin/bash
REL=0.1-1
SID=009
##############################################################################
#
#    namcd-mon.sh - Monitor and restart nds if it crashes
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
# Date Created: Tue Jun 09 10:51:00 2015
# Last updated: Tue Jun 09 11:17:00 2015
# Crontab command: */5 * * * * /root/bin/namcd-mon.sh
# Supporting file: None
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/namcdmon.log"

function initlog() { 
  if [ -e /var/log/namcdmon.log ]; then
    echo "log file exists" > /dev/null
  else
    touch /var/log/namcdmon.log
    echo "Logging started at ${TS}" > ${LOG}
    echo "All actions are being performed by the user: ${USER}" >> ${LOG}
    echo " " >> ${LOG}
  fi
}

function logit() { 
  echo $TS $HOST: $* >> ${LOG}
}

initlog

# Check for the current status of the Linux User Management daemon namcd
 /usr/sbin/rcnamcd status &>/dev/null
 namcdReturnCode=$?

logit "Return Code for NAMCD: $namcdReturnCode"

# Check for the current status of the name service cache daemon nscd
/etc/init.d/nscd status &>/dev/null
nscdReturnCode=$?

logit "Return Code for NSCD: $nscdReturnCode"

# Act if namcd is down
if [ $namcdReturnCode == "0" ]; then
  logit "NAMCD service is running"
else
  if [ -n $EMAIL ]; then
    echo -e "namcd, Linux User Management, is not running on: $HOST" | mail -s "namcd is DOWN" $EMAIL
  fi
  logit "namcd (LUM) is not running on $HOST, attempting restart now"
  /usr/sbin/rcnamcd stop
  /usr/sbin/nscd restart
  /usr/sbin/namcd start
  logit "namcd and nscd restart attempt complete"
  /usr/sbin/rcnamcd status $>/dev/null
  namcdReturnCode2=$?
  if [ $namcdReturnCode2 = 0 ]; then
    logit "namcd (LUM) successfully restarted"
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n $EMAIL ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $HOST. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
fi

# Act if nscd is down
if [ $nscdReturnCode == "0" ]; then
  logit "NSCD service is running"
else
  if [ -n $EMAIL ]; then
    echo -e "nscd, Name Service Cache Daemon, is not running on: $HOST" | mail -s "nscd is DOWN" $EMAIL
  fi
  logit "nscd is not running on $HOST, attempting restart now"
  /usr/sbin/nscd restart
  logit "nscd restart attempt complete"
  /etc/init.d/nscd status $>/dev/null
  nscdReturnCode2=$?
  if [ $nscdReturnCode2 = 0 ]; then
    logit "nscd successfully restarted"
  else
    logit "For some reason the last restart of nscd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/messages) for errors."
    if [ -n $EMAIL ]; then
      echo -e "The restart of the nscd daemon has failed and namcd may not be running on $HOST. Please attempt a manual restart, and check the log (/var/log/messages) for errors." | mail -s "ATTENTION: nscd restart on $HOST failed, please investigate!" $EMAIL
    fi
  fi
fi

echo "--------------------------------------------------------" >> $LOG

# Finished
exit 1

