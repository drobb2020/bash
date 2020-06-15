#!/bin/bash - 
#===============================================================================
#
#          FILE: namcd-mon (2).sh
# 
#         USAGE: ./namcd-mon (2).sh 
# 
#   DESCRIPTION: Monitor and restart namcd if it crashes
#
#                Copyright (C) 2016  David Robb
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
#       OPTIONS: */5 * * * * /root/bin/namcd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Jun 09 2015 10:51
#  LAST UPDATED: Sun Jun 19 2016 11:15
#      REVISION: 1
#     SCRIPT ID: 062
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.2
sid=062                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/namcd-mon.log'                    # logging (if required)

function initlog() { 
  if [ -e ${log} ]; then
    echo "log file exists" > /dev/null
  else
    touch ${log}
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function logit() { 
  echo $ts $host: $* >> ${log}
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
  if [ -n $email ]; then
    echo -e "namcd, Linux User Management, is not running on: $host" | mail -s "namcd is DOWN" $email
  fi
  logit "namcd (LUM) is not running on $host, attempting restart now"
  /etc/init.d/namcd stop
  /etc/init.d/nscd restart
  /etc/init.d/namcd start
  logit "namcd and nscd restart attempt complete"
  /usr/sbin/rcnamcd status $>/dev/null
  namcdReturnCode2=$?
  if [ $namcdReturnCode2 = 0 ]; then
    logit "namcd (LUM) successfully restarted"
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n $Eemail ]; then
      echo -e "The restart of the namcd daemon has failed and namcd may not be running on $host. Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors." | mail -s "ATTENTION: namcd restart on $host failed, please investigate!" $email
    fi
  fi
fi

# Act if nscd is down
if [ $nscdReturnCode == "0" ]; then
  logit "NSCD service is running"
else
  if [ -n $email ]; then
		echo -e "Name Service Cache Daemon (nscd), is not running on: $host" | mail -s "nscd is DOWN" $email
  fi
  logit "nscd is not running on $host, attempting restart now"
  /etc/init.d/nscd restart
  logit "nscd restart attempt complete"
  /etc/init.d/nscd status $>/dev/null
  nscdReturnCode2=$?
  if [ $nscdReturnCode2 = 0 ]; then
    logit "nscd successfully restarted"
  else
    logit "For some reason the last restart of nscd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/messages) for errors."
    if [ -n $emailL ]; then
      echo -e "The restart of the nscd daemon has failed and namcd may not be running on $host. Please attempt a manual restart, and check the log (/var/log/messages) for errors." | mail -s "ATTENTION: nscd restart on $host failed, please investigate!" $Eemail
    fi
  fi
fi

echo "--------------------------------------------------------" >> $LOG

# Finished
exit 1

