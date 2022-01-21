#!/bin/bash - 
#===============================================================================
#
#          FILE: cifsd-mon.sh
# 
#         USAGE: ./cifsd-mon.sh 
# 
#   DESCRIPTION: Monitor and restart novell-cifsd if it crashes
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
#       OPTIONS: */5 * * * * /root/bin/cifsd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Dec 07 2016 07:50
#  LAST UPDATED: Thu Mar 08 2018 11:10
#       VERSION: 0.1.4
#     SCRIPT ID: 075
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=cifsd-monitor                              # email sender
email=ssc_cas_admin@rcmp-grc.gc.ca               # email recipient(s)
log='/var/log/cifs/cifsd-mon.log'                # log name and location (if required)
ccpath=/root/bin                                 # path to core-checker.sh script
#===============================================================================
function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch "$log"
    echo "Logging started at ${ts}";
    echo "All actions are being performed by the user: ${user}";
    echo " " >> "$log"
  fi
}

function logit() { 
  echo "$ts" "$host": "$@" >> "$log"
}

initlog

# Check for the current status of the novell-cifs daemon
/etc/init.d/novell-cifs status &>/dev/null
  cifsdReturnCode=$?
logit "Return Code for novell-cifs: $cifsdReturnCode"

function mail_body1() { 
echo -e "novell-cifs is not running on $host. An automated restart is being attempted now. If this restart fails you will receive a second message.\nA core may have been generated when novell-cifsd died, the core-checker script has been called to investigate. You will get a separate email if a core was generated.\nPlease review the cifs log (/var/log/cifs/cifs.log) to see if there was a reason logged for the daemon stopping."
}

function mail_body2() { 
echo -e "The restart of the novell-cifs daemon has failed and may not be running on $host. Please logon to the server terminal and attempt a manual restart. Don't forget to check the log (/var/log/cifs/cifs.log) for errors!"
}

# Act if cifsd is down
if [ $cifsdReturnCode == "0" ]; then
  logit "novell-cifs service is running"
else
  if [ -n "$email" ]; then
    mail_body1 | mail -s "novell-cifs is DOWN on $host and will be restarted automatically" -r $mfrom $email
  fi
  logit "novell-cifs (CIFSD) is not running on $host, attempting restart now"
  /etc/init.d/novell-cifs stop
  /etc/init.d/novell-cifs start
  logit "novell-cifs restart attempt complete"
  sleep 15
  # Ensure novell-cifsd is running
  /etc/init.d/novell-cifs status $>/dev/null
  cifsdReturnCode2=$?
  if [ $cifsdReturnCode2 = 0 ]; then
    logit "Confirmed novell-cifs (CIFSD) successfully restarted"
  else
    logit "For some reason the last restart of novell-cifs failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/cifs/cifs.log) for errors."
    if [ -n "$email" ]; then
      mail_body2 | mail -s "ATTENTION: novell-cifs restart on $host failed, please investigate!" -r $mfrom $email
    fi
  fi
fi

# Check if a core was generated (cause of the crash)
if [ $cifsdReturnCode == "0" ]; then
  echo -e "novell-cifsd did not stop, don't check for a core" > /dev/null
else
  grep "cifsd" /var/core/ > /tmp/cifs_core_ck_$$.txt
  if [ -z "$(cat /tmp/cifs_core_ck_$$.txt)" ]; then
    logit "No core was generated when novell-cifsd stopped"
  else
    logit "A core was generated when cifsd stopped, calling core-checker.sh"
    . $ccpath/core-checker.sh
    rm -f /tmp/cifs_core_ck_$$.txt
  fi
fi

# Finished
exit 0
