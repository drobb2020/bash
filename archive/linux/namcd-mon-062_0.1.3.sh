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
#   LAST UDATED: Mon Mar 12 2018 08:37
#       VERSION: 0.1.3
#     SCRIPT ID: 062
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.3                                    # version number of the script
sid=062                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=namcd-monitor                              # email sender
email=root                                       # email recipient(s)
log='/var/log/namcd-mon.log'                     # log name and location (if required)
#===============================================================================

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
  if [ -n $email ]; then
    mail_body1 | mail -s "namcd is DOWN" -r $mfrom $email
  fi
  logit "namcd (LUM) is not running on $host, attempting restart now"
  /etc/init.d/namcd stop
  /etc/init.d/nscd restart
  /etc/init.d/namcd start
  logit "namcd and nscd restart attempt complete"
	sleep 5
  /usr/sbin/rcnamcd status $>/dev/null
  namcdReturnCode2=$?
  if [ $namcdReturnCode2 = 0 ]; then
    logit "namcd (LUM) successfully restarted"
  else
    logit "For some reason the last restart of namcd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
    if [ -n $Eemail ]; then
      mail_body2 | mail -s "ATTENTION: namcd restart on $host failed, please investigate!" -r $mfrom $email
    fi
  fi
fi

# Act if nscd is down
if [ $nscdReturnCode == "0" ]; then
  logit "NSCD service is running"
else
  if [ -n $email ]; then
		mail_body3 | mail -s "nscd is DOWN" -r $mfrom $email
  fi
  logit "nscd is not running on $host, attempting restart now"
  /etc/init.d/nscd restart
  logit "nscd restart attempt complete"
	sleep 5
  /etc/init.d/nscd status $>/dev/null
  nscdReturnCode2=$?
  if [ $nscdReturnCode2 = 0 ]; then
    logit "nscd successfully restarted"
  else
    logit "For some reason the last restart of nscd failed."
    logit "The daemon may be dead at this time."
    logit "Please attempt a manual restart, and check the log (/var/log/messages) for errors."
    if [ -n $emailL ]; then
      mail_body4 | mail -s "ATTENTION: nscd restart on $host failed, please investigate!" -r $mfrom $Eemail
    fi
  fi
fi

# Finished
exit 1

