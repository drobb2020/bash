#!/bin/bash - 
#===============================================================================
#
#          FILE: namcd-mon.sh
# 
#         USAGE: ./namcd-mon.sh 
# 
#   DESCRIPTION: Monitor and restart namcd if it crashes
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
#       OPTIONS: */5 * * * * /root/bin/namcd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Jun 09 2015 10:51
#  LAST UPDATED: Tue Aug 20 2019 13:31
#       VERSION: 0.2.0
#     SCRIPT ID: 062
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")               # general date|time stamp
host=$(hostname)                     # hostname of the local server
user=$(whoami)                       # who is running the script
mfrom=namcd-monitor                  # email sender
email=root                           # email recipient(s)
log='/var/log/namcd-mon.log'         # log name and location (if required)
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

# Check for the current status of the Linux User Management daemon namcd
# /usr/sbin/rcnamcd status &>/dev/null
/usr/bin/systemctl status namcd.service &>/dev/null
namcdReturnCode=$?

logit "Return Code for NAMCD: $namcdReturnCode"

# Check for the current status of the name service cache daemon nscd
# /etc/init.d/nscd status &>/dev/null
/usr/bin/systemctl status nscd.service &>/dev/null
nscdReturnCode=$?

logit "Return Code for NSCD: $nscdReturnCode"

function mail_body1() { 
echo -e "namcd, Linux User Management, is not running on $host. An automatic restart is being attempted, if this should fail you will receive a second email."
}

function mail_body2() { 
echo -e "The restart of the namcd daemon has failed and namcd may not be running on $host. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
}

function mail_body3() { 
echo -e "Name Service Cache Daemon (nscd), is not running on $host. An automatic restart is being attempted, if this should fail you will receive a second email."
}

function mail_body4() { 
echo -e "The restart of the nscd daemon has failed and namcd may not be running on $host. Please attempt a manual restart, and check the log (/var/log/messages) for errors."
}

# Act if namcd is down
if [ $namcdReturnCode == "0" ]; then
  logit "NAMCD service is running"
else
  if [ -n "$email" ]; then
    mail_body1 | mail -s "namcd is DOWN" -r $mfrom $email
  fi
  logit "namcd (LUM) is not running on $host, attempting restart now"
  # /etc/init.d/namcd stop
  # /etc/init.d/nscd restart
  # /etc/init.d/namcd start
  /usr/bin/systemctl stop namcd.service
  /usr/bin/systemctl stop nscd.service
  /usr/bin/systemctl start nscd.service
  /usr/bin/systemctl start namcd.service
  logit "namcd and nscd restart attempt complete"
	sleep 5
  # /usr/sbin/rcnamcd status &>/dev/null
  /usr/bin/systemctl status namcd.service &>/dev/null
  namcdReturnCode2=$?
  if [ $namcdReturnCode2 = 0 ]; then
    logit "namcd (LUM) successfully restarted"
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [[ -n $email ]]; then
      mail_body2 | mail -s "ATTENTION: namcd restart on $host failed, please investigate!" -r $mfrom $email
    fi
  fi
fi

# Act if nscd is down
if [ $nscdReturnCode == "0" ]; then
  logit "NSCD service is running"
else
  if [[ -n $email ]]; then
		mail_body3 | mail -s "nscd is DOWN" -r $mfrom $email
  fi
  logit "nscd is not running on $host, attempting restart now"
  # /etc/init.d/nscd restart
  /usr/bin/systemctl restart nscd.service
  logit "nscd restart attempt complete"
	sleep 5
  # /etc/init.d/nscd status $>/dev/null
  /usr/bin/systemctl status nscd.service &>/dev/null
  nscdReturnCode2=$?
  if [ $nscdReturnCode2 = 0 ]; then
    logit "nscd successfully restarted"
  else
    logit "For some reason the last restart of nscd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/messages) for errors."
    if [[ -n $emailL ]]; then
      mail_body4 | mail -s "ATTENTION: nscd restart on $host failed, please investigate!" -r $mfrom $email
    fi
  fi
fi

# Finished
exit 0
