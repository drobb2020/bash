#!/bin/bash
REL=0.10-06
##############################################################################
#
#    ndsd-mon.sh - Monitor and restart nds if it crashes
#    Copyright (C) 2012  David Robb
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
# Date Created: Thu Apr 12 14:48:47 2012 
# Last updated: Thu Dec 20 12:48:16 2012 
# Crontab command: */5 * * * * /root/bin/ndsd-mon.sh
# Supporting file: None
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
LOG="/var/log/ndsdmon.log"

function initlog() { 
   if [ -e /var/log/ndsdmon.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/ndsdmon.log
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
 /usr/sbin/rcndsd status &>/dev/null
 ndsdReturnCode=$?

logit "Return Code for NDSD: $ndsdReturnCode"

# Check for the current status of the Linux User Management daemon namcd
 /usr/sbin/rcnamcd status &>/dev/null
 namcdReturnCode=$?

logit "Return Code for NAMCD: $namcdReturnCode"

# Act if ndsd is down
if [ $ndsdReturnCode == "0" ] 
    then
	logit "NDSD service is running"
    else
	# printf "$DTSTAMP eDirectory is not running on server: $HOST | mail -s "eDirectory is DOWN" @txt.att.net
	logit "eDirectory is not running on server, attempting restart now"
	/usr/sbin/rcndsd restart
	logit "NDSD restart attempt complete"
	/usr/sbin/rcnamcd restart
	echo "$DTSTAMP $HOST: NAMCD restarted after NDSD restart" | tee -a $LOGFILE
fi

# Act if namcd is down
if [ $namcdReturnCode == "0" ]
    then
	logit "NAMCD service is running"
    else
	# prinf "$DTSTAMP namcd (LUM) is not running on server: $HOST | mail -s "eDirectory is DOWN" @txt.att.net
 	logit "namcd (LUM) is not running on server, attempting restart now"
	/usr/sbin/rcnamcd restart
	logit "NAMCD restart attempt complete"
 fi

 echo "--------------------------------------------------------" >> $LOG

# Finished
exit
