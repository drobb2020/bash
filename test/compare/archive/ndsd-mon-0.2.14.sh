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
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Thu Apr 12 2012 14:48
#  LAST UPDATED: Tue Dec 12 2017 11:23
#      REVISION: 14
#     SCRIPT ID: 010
#===============================================================================
version=0.2.14                              # script version
sid=010                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # email accounts
log='/var/log/ndsd-mon.log'                 # logging (if required)
ccpath=/scripts/ldap/monitoring  	    # path to core-checker.sh script

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
logit "Return Code for NDSD: $ndsdReturnCode"

# Check for the current status of the Linux User Management daemon namcd
/etc/init.d/namcd status &>/dev/null
  namcdReturnCode=$?
logit "Return Code for NAMCD: $namcdReturnCode"

# Act if ndsd is down
if [ $ndsdReturnCode == "0" ]; then
  logit "NDSD service is running"
else
  if [ -n $email ]; then
    echo -e "eDirectory is not running on: $host. An automatic restart is being attempted now. If this restart fails you will recieve a second email.\nA core may have been generated when ndsd died, the core-checker script has been called to investigate. You will get a separate email if a core was generated.\nPlease review the ndsd log (/var/opt/novell/eDirectory/log/ndsd.log) to see if there was a reason logged for the daemon stopping. " | mail -s "eDirectory is DOWN on $host and will be restarted automatically" $email
  fi
  logit "eDirectory is not running on $host, attempting restart now"
  /usr/sbin/rcndsd restart
  logit "NDSD restart attempt complete"
  sleep 15
  # Ensure NDSD is running
  /usr/sbin/rcndsd status &>/dev/null
  ndsdReturnCode2=$?
  if [ $ndsdReturnCode2 == 0 ]; then
    logit "Confirmed ndsd daemon successfully restarted."
  else
    logit "For some reason the restart of ndsd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
    if [ -n $email ]; then
      echo -e "The restart of the ndsd daemon has failed and ndsd may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors." | mail -s "ATTENTION: ndsd restart on $host failed please investigate!" $email
    fi
  fi

  # Restart namcd if you restart ndsd
  /usr/sbin/rcnamcd restart
  logit "namcd restarted after ndsd restart"
  /usr/sbin/rcnamcd status &>/dev/null
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
    echo -e "namcd, Linux User Management, is not running on: $host. An automatic restart is being attempted now. If this restart fails you will recieve a second email.\nA core may have been generated when namcd died, the core-checker script has been called to investigate. You will get a separate email if a core was generated.\nPlease review the ndsd log (/var/log//novell-lum/namcd.log) to see if there was a reason logged for the daemon stopping." | mail -s "namcd is DOWN and will be restarted automatically" $email
  fi
  logit "namcd (LUM) is not running on $host, attempting restart now"
  /usr/sbin/rcnamcd restart
  logit "namcd restart attempt complete"
  /usr/sbin/rcndsd status &>/dev/null
  ndsdReturnCode3=$?
  if [ $ndsdReturnCode3 == 0 ]; then
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

# Check if a ndsd core was generated (cause of crash)
if [ $ndsdReturnCode == "0" ]; then
  echo "ndsd did not stop, don't check for a core" > /dev/null
else
  core=$(ls /var/core/ | grep ndsd > /tmp/ndsd_core_ck_$$.txt)
  if [ -z $(cat /tmp/ndsd_core_ck_$$.txt) ]; then
    logit "No core was generated when ndsd stopped"
  else
    logit "A core was generated when ndsd stopped, calling core-checker.sh"
    . $ccpath/core-checker.sh
    rm -f /tmp/ndsd_core_ck_$$.txt
  fi
fi

# Check if a namcd core was generated (cause of crash)
if [ $namcdReturnCode == "0" ]; then
  echo "namcd did not stop, don't check for a core" > /dev/null
else
  core=$(ls /var/core/ | grep namcd > /tmp/namcd_core_ck_$$.txt)
  if [ -z $(cat /tmp/namcd_core_ck_$$.txt) ]; then
    logit "No core was generated when namcd stopped"
  else
    logit "A core was generated when namcd stopped, calling core-checker.sh"
    . $ccpath/core-checker.sh
    rm -f /tmp/namcd_core_ck_$$.txt
  fi
fi

# Finished
exit 1

