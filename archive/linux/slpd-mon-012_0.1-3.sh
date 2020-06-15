#!/bin/bash
REL=0.1-3
SID=012
##############################################################################
#
#    slpd-mon.sh - Monitor and restart SLP daemon if it crashes
#    Copyright (C) 2013  David Robb
#
##############################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
# Date Created: Tue Feb 12 12:53:28 2013 
# Last updated: Wed May 27 11:45:48 2015 
# Crontab command: */5 * * * * /root/bin/slpd-mon.sh
# Supporting file: None
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/slpdmon.log"

function initlog() { 
   if [ -e /var/log/slpdmon.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/slpdmon.log
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo $TS $HOST: $* >> ${LOG}
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
	if [ -n $EMAIL ]
	    then
		echo -e "Service Location Protocol daemon is not running on server: $HOST" | mail -s "SLPD is DOWN" $EMAIL
	fi
	logit "SLP is not running on the server, attempting a restart now"
	/usr/sbin/rcslpd restart
	logit "SLPD restart attempt complete"
	/etc/init.d/slpd status &>/dev/null
	slpReturnCode2=$?
	if [ $slpReturnCode2 == "0" ]
	    then
		logit "Verified that slpd is now running"
		echo -e "Service Location Protocol daemon is successfully restarted on server: $HOST" | mail -s "SLPD is back UP" $EMAIL
	    else
		echo -e "The restart of the slpd daemon failed, please investigate $HOST" | mail -s "SLPD Restart Failed" $EMAIL
	fi 
fi

echo "--------------------------------------------------------" >> $LOG

# Finished
exit 1

