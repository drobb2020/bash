#!/bin/bash - 
#===============================================================================
#
#          FILE: slpd-mon.sh
# 
#         USAGE: ./slpd-mon.sh 
# 
#   DESCRIPTION: Monitor and restart SLP daemon if it crashes
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
#       OPTIONS: */5 * * * * /root/bin/slpd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Feb 12 2013 12:53
#  LAST UPDATED: Sun Jun 19 2016 11:41
#      REVISION: 4
#     SCRIPT ID: 013
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.5
sid=013                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/slpd-mon.log'                     # logging (if required)

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

# Check for the current status of the eDirectory daemon ndsd
 /usr/sbin/rcslpd status &>/dev/null
 slpdReturnCode=$?

logit "Return Code for SLPD: $slpdReturnCode"

# Act if slpd is down
if [ $slpdReturnCode == "0" ] 
    then
	logit "SLPD service is running"
    else
	if [ -n $email ]
	    then
		echo -e "Service Location Protocol daemon is not running on server: $host" | mail -s "SLPD is DOWN" $email
	fi
	logit "SLP is not running on the server, attempting a restart now"
	/usr/sbin/rcslpd restart
	logit "SLPD restart attempt complete"
	/etc/init.d/slpd status &>/dev/null
	slpReturnCode2=$?
	if [ $slpReturnCode2 == "0" ]
	    then
		logit "Verified that slpd is now running"
		echo -e "Service Location Protocol daemon is successfully restarted on server: $host" | mail -s "SLPD is back UP" $email
	    else
		echo -e "The restart of the slpd daemon failed, please investigate $host" | mail -s "SLPD Restart Failed" $email
	fi 
fi

echo "--------------------------------------------------------" >> $LOG

# Finished
exit 1

