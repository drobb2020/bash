#!/bin/bash - 
#===============================================================================
#
#          FILE: ndsd-mon.sh
# 
#         USAGE: ./ndsd-mon.sh 
# 
#   DESCRIPTION: Monitor and restart nds if it crashes
#
#                Copyright (C) 2015  David Robb
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
#       OPTIONS: */5 * * * * /root/bin/ndsd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Apr 12 2012 14:48
#  LAST UPDATED: Wed Aug 16 2017 08:31
#      REVISION: 13
#     SCRIPT ID: 010
#===============================================================================
version=0.2.13                              # script version
sid=010                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=chandlar.pigeon@rcmp-grc.gc.ca,david.robb@rcmp-grc.gc.ca   # email accounts
log='/var/log/ndsd-mon.log'                 # logging (if required)

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

# Check for the current status of the eDirectory daemon ndsd
 /etc/init.d/ndsd status &>/dev/null
 ndsdReturnCode=$?
 # logit "Return Code for NDSD: $ndsdReturnCode"

# Check for the current status of the Linux User Management daemon namcd
 /etc/init.d/namcd status &>/dev/null
 namcdReturnCode=$?
 # logit "Return Code for NAMCD: $namcdReturnCode"

# Act if ndsd is down
if [ $ndsdReturnCode == "0" ]; then
  logit "NDSD service is running"
else
  if [ -n $email ]; then
    echo -e "eDirectory is not running on: $host. A automatic restart is being attempted now. If this restart fails you will recieve a second email." | mail -s "eDirectory is DOWN on $host" $email
  fi
  logit "eDirectory is not running on $host, attempting restart now"
  /etc/init.d/ndsd restart
  logit "NDSD restart attempt complete"
  sleep 15
  # Ensure NDSD is running
  /etc/init.d/ndsd status &>/dev/null
  ndsdReturnCode2=$?
  if [ $ndsdReturnCode2 == 0 ]; then
    logit "Confirmed ndsd daemon successfully restarted."
  else
    logit "For some reason the restart of ndsd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n $email ]; then
      echo -e "The restart of the ndsd daemon has failed and ndsd may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors." | mail -s "ATTENTION: ndsd restart on $host failed, please investigate!" $email
    fi
  fi
  # Restart namcd if you restart ndsd
  /etc/init.d/namcd restart
  logit "namcd restarted after ndsd restart"
  sleep 15
  /etc/init.d/namcd status &>/dev/null
  namcdReturnCode2=$?
  if [ $namcdReturnCode2 == 0 ]; then
    logit "namcd daemon successfully restarted."
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n $email ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $host. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $host failed, please investigate!" $email
    fi
  fi
fi

# Act if namcd is down
if [ $namcdReturnCode == "0" ]; then
  logit "NAMCD service is running"
else
  if [ -n $email ]; then
    echo -e "namcd, Linux User Management, is not running on: $host" | mail -s "namcd is DOWN" $email
  fi
  logit "namcd (LUM) is not running on $host, attempting restart now"
  /etc/init.d/namcd restart
  logit "namcd restart attempt complete"
  sleep 15
  /etc/init.d/namcd status &>/dev/null
  namcdReturnCode3=$?
  if [ $namcdReturnCode3 == 0 ]; then
    logit "namcd daemon (Linux User Management) successfully restarted."
  else
    logit "For some reason the restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n $email ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $host. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $host failed, please investigate!" $email
    fi
  fi
fi

# Finished
exit 1

