#!/bin/bash - 
#===============================================================================
#
#          FILE: iprint-mon.sh
# 
#         USAGE: ./iprint-mon.sh 
# 
#   DESCRIPTION: Monitor, log and restart iprint services if they stop or crash
#
#                Copyright (C) 2017  David Robb
#
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
#       OPTIONS: */5 * * * * /root/bin/iprint-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus Software (Canada) ltd.
#       CREATED: Thu Nov 16 2017 09:01
#  LAST UPDATED: Thu Apr 19 2018 15:04
#      REVISION: 0.1.3
#     SCRIPT ID: 011
#===============================================================================
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
mfrom=iprint-monitor                        # email sender
email=                                      # accounts for email notifications
log='/var/log/iprint-mon.log'               # logging (if required)

function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch "$log"
    echo "Logging started at ${ts}" > "$log"
    echo "All actions are being performed by the user: ${user}" >> "$log"
    echo " " >> "$log"
  fi
}

function logit() { 
  echo "$ts" "$host": "$@" >> "$log"
}

initlog

# Check for the current status of the iprint manager daemon ipsmd
function mail_body1() {
echo -e "The iPrint Manager IPSMD is not running on: $host. An automatic restart is being attempted now. If this restart fails you will receive a second email."
}

function mail_body2() {
echo -e "The restart of the iPrint manager IPSMD daemon has failed and the iPrint Manager may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/log/iprint/ipsmd.log) for errors."
}

if [ -e /etc/opt/novell/iprint/conf/ipsmd.conf ]; then
  /opt/novell/iprint/init.d/novell-ipsmd status &>/dev/null
  ipsmdReturnCode=$?
  logit "Return Code for iPrint Manager IPSMD: $ipsmdReturnCode"
  # Act if ipsmd is down
  if [ $ipsmdReturnCode == "0" ]; then
    logit "iPrint Manager IPSMD service is running as expected."
  else
    if [ -n "$email" ]; then
      mail_body1 | mail -s "iPrint Manager IPSMD is DOWN on $host" -r "$mfrom" "$email"
    fi
    logit "iPrint Manager IPSMD is not running on $host, attempting restart now"
    /opt/novell/iprint/init.d/novell-ipsmd restart
    logit "iPrint Manager IPSMD restart attempt complete"
    sleep 15

    # Ensure IPSMD is running
    /opt/novell/iprint/init.d/novell-ipsmd status &>/dev/null
    ipsmdReturnCode2=$?
    
    if [ $ipsmdReturnCode2 == 0 ]; then
      logit "Confirmed that the iPrint Manager IPSMD daemon successfully restarted."
    else
      logit "For some reason the restart of the iPrint Manager IPSMD failed."
      logit "The daemon may be dead at this time."
      logit "Please attempt a manual restart, and check the log (/var/opt/novell/log/iprint/ipsmd.log) for errors."
      if [ -n "$email" ]; then
        mail_body2 | mail -s "ATTENTION: The restart of iPrint Manager on $host failed, please investigate!" -r "$mfrom" "$email"
      fi
    fi
  fi
else
  logit "This server does not host the iPrint Manager."
fi

# Check for the current status of the iprint driver store daemon idsd
function mail_body3() { 
echo -e "The iPrint Driver Store (IDSD) is not running on: $host. An automatic restart is being attempted now. If this restart fails you will receive a second email."
}

function mail_body4() { 
echo -e "The restart of The iPrint Driver Store (IDSD) daemon has failed and the iPrint Driver Store may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/log/iprint/idsd.log) for errors."
}

if [ -e /etc/opt/novell/iprint/conf/idsd.conf ]; then
  /opt/novell/iprint/init.d/novell-idsd status &>/dev/null
  idsdReturnCode=$?
  logit "Return Code for iPrint Driver Store IDSD: $idsdReturnCode"
  # Act if iPrint Driver Store IDSD is down
  if [ $idsdReturnCode == "0" ]; then
    logit "iPrint Driver Store IDSD service is running as expected."
  else
    if [ -n "$email" ]; then
      mail_body3 | mail -s "iPrint Driver Store IDSD is DOWN on $host" -r "$mfrom" "$email"
    fi
    logit "iPrint Driver Store (IDSD) is not running on $host, attempting restart now"
    /opt/novell/iprint/init.d/novell-idsd restart
    logit "iPrint Driver Store IDSD restart attempt complete"
    sleep 15
    /opt/novell/iprint/init.d/novell-idsd status &>/dev/null
    idsdReturnCode2=$?
    if [ $idsdReturnCode2 == 0 ]; then
      logit "Confirmed that the iPrint Driver Store (IDSD) successfully restarted."
    else
      logit "For some reason the restart of The iPrint Driver Store (IDSD) failed."
      logit "The daemon may be dead at this time."
      logit "Please attempt a manual restart, and check the log (/var/opt/novell/log/iprint/idsd.log) for errors."
      if [ -n "$email" ]; then
        mail_body4 | mail -s "ATTENTION: The iPrint Driver Store (IDSD) restart on $host failed, please investigate!" -r "$mfrom" "$email"
      fi
    fi
  fi
else
  logit "This server does not host an iPrint Driver Store."
fi

# Finished
exit 0
