#!/bin/bash
REL=0.1-1
SID=010
##############################################################################
#
#    restartndsd.sh - SSC Restart script for ndsd daemon
#    Copyright (C) 2014  David Robb
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#
##############################################################################
# Date Created: Wed Jul 23 07:36:17 2014 
# Last updated: Wed May 27 11:37:05 2015 
# Crontab command: Remember to stagger the restart time on servers within the
#                  same replica ring
# Supporting file: None
# Additional notes: 
##############################################################################
#Variables
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/ndsdrestart.log"

function initlog() { 
   if [ -e /var/log/ndsdrestart.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/ndsdrestart.log
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo -e $TS $HOST: $* >> ${LOG}
}

initlog
logit "v$REL SSC ndsd restart script"
logit "=============================="
logit "------------------------------"
logit "NDSD daemon restart"
logit "------------------------------"
# Check current status of daemon
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode=$?
if [ $ndsdReturnCode == 0 ]
    then
        logit "Restart of ndsd issued by cron job on $HOST."
        /etc/init.d/ndsd restart | tee -a $LOG
	logit "Restart command issued."
fi

# Check new status of daemon (lets hope it's running)
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode2=$?
if [ $ndsdReturnCode2 == 0 ]
    then
        logit "ndsd daemon successfully restarted."
	if [ -n $EMAIL ]
	    then
		echo -e "The ndsd daemon has successfully restarted on $HOST as per the monthly cron schedule. Please review the /var/log/ndsdrestart.log for any additional details." | mail -s "ndsd restarted on $HOST" $EMAIL
	fi
    else
        logit "For some reason the last restart of ndsd failed."
        logit "The daemon may be dead at this time."
        logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
	if [ -n $EMAIL ] 
	    then
		echo -e "The scheduled restart of the ndsd daemon has failed and ndsd may not be running on $HOST. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors." | mail -s "ATTENTION: ndsd restart on $HOST failed, please investigate!" $EMAIL
	fi
fi

logit "------------------------------"

exit 1

