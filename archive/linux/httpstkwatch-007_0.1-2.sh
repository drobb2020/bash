#!/bin/bash
REL=0.1-2
SID=007
##############################################################################
#
#    httpstkwatch.sh - Script to monitor the httpstkd daemon
#    Copyright (C) 2012  David Robb
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
# Date Created: Wed Dec 19 08:47:15 2012 
# Last updated: Wed May 27 11:23:30 2015 
# Crontab command: */5 * * * * root /root/bin/httpstkwatch.sh
# Supporting file: None
# Additional notes: Set the crontab interval to what the users can tolerate as
#                   an outage, e.g. 5, 10, or 15 minutes.
##############################################################################
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
LOG="/var/log/httpstkdwatch.log"

function initlog() { 
   if [ -e /var/log/httpstkdwatch.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/httpstkdwatch.log
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo $TS $HOST: $* >> ${LOG}
}

initlog

# Check the current status of novel-httpstkd
if [ -e /var/run/httpstkd.pid ] 
    then
	PIDD=$(cat /var/run/httpstkd.pid)
	PS=$(ps aux | grep httpstkd | grep -v grep | cut -f 7 -d " " | sed -n '1p')
	if [ $PIDD -eq $PS ]
	    then
		logit "novell-httpstkd appears to be running correctly"
	    else
		logit "PID file exists but the daemon is dead"
		    rm -f /var/run/httpstkd.pid
		    kill -9 $PIDD
		    /etc/init.d/novell-httpstkd restart
		logit "novell-httpstkd daemon has been restarted"
	fi
    else
	logit "httpstkd.pid does not exist, daemon is stopped, going to do a restart."
	/etc/init.d/novell-httpstkd start
fi

exit 1

