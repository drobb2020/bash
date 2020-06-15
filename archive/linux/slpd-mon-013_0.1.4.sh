#!/bin/bash - 
#===============================================================================
#
#          FILE: slpd-mon.sh
# 
#         USAGE: ./slpd-mon.sh 
# 
#   DESCRIPTION: Monitor and restart SLP daemon if it crashes
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
#       OPTIONS: */5 * * * * /root/bin/slpd-mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Feb 12 2013 12:53
#  LAST UPDATED: Mon Jul 20 2015 09:17
#      REVISION: 4
#     SCRIPT ID: 013
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.4
sid=013                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/slpd-mon.log'                 # logging (if required)

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

