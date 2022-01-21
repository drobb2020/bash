#!/bin/bash - 
#===============================================================================
#
#          FILE: iprint-reset.sh
# 
#         USAGE: ./iprint-reset.sh
# 
#   DESCRIPTION: Restart the iprint manager and apache2 services if iManager shows
#                the iPrint manager as down even though it is running on the server.
#                As documented in TID #7018335.
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
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Apr 30 2018 10:33
#  LAST UPDATED: Mon Apr 30 2018 11:00
#       VERSION: 0.1.0
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
mfrom=iprint-restart                             # email sender
email=root                                       # email recipient(s)
log='/var/log/iprint-restart.log'                # log name and location (if required)
#===============================================================================

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
echo -e "The iPrint Manager IPSMD has been restarted on: $host. This was done to resolve the issue of iManager showing the Print Manager as stopped."
}

function restart_ipsmd() {
/etc/init.d/novell-ipsmd restart
sleep 5
}

function restart_apache2() {
/etc/init.d/apache2 restart
sleep 5
}

# Restart novell-ipsmd and apache2 so iManager sees the print manager as active
if [ -e /etc/opt/novell/iprint/conf/ipsmd.conf ]; then
  /opt/novell/iprint/init.d/novell-ipsmd status &>/dev/null
  ipsmdReturnCode=$?
  # Restart ipsmd and apache2
  if [ $ipsmdReturnCode == "0" ]; then
    logit "iPrint Manager IPSMD and apache2 are about to be restarted."
    restart_ipsmd; restart_apache2
		mail_body1 | mail -s "iPrint Manager and apache2 restarted on $host -r $mfrom $email"
  else
    if [ -n "$email" ]; then
      logit "iPrint Manager IPSMD is not running on $host, attempting a start now"
      /opt/novell/iprint/init.d/novell-ipsmd start
      logit "iPrint Manager IPSMD restart attempt complete"
      sleep 5
	  fi
    # Ensure IPSMD is running
    /opt/novell/iprint/init.d/novell-ipsmd status &>/dev/null
    ipsmdReturnCode2=$?
		/etc/init.d/apache2 status &>/dev/null
		apache2ReturnCode2=$?
    if [ $ipsmdReturnCode2 == 0 ] && [ $apache2ReturnCode2 == 0 ]; then
      logit "Confirmed that the iPrint Manager IPSMD daemon and apache2 successfully restarted."
    else
      logit "For some reason the restart of the iPrint Manager IPSMD or apache2 failed."
			logit "The daemon(s)) may be dead at this time."
      logit "Please attempt a manual restart, and check the logs for errors."
      if [ -n "$email" ]; then
        mail_body2 | mail -s "ATTENTION: The restart of iPrint Manager or apache2 on $host failed, please investigate!" -r $mfrom $email
      fi
    fi
  fi
fi

# Finished
exit 1

