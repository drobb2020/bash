#!/bin/bash - 
REL=0.1-1
SID=005
##############################################################################
#
#    edir-procwatch.sh - script to troubleshoot DFS
#    Copyright (C) 2015  David Robb
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
# Date Created: Tue Mar 03 11:44:24 2015 
# Last updated: Wed May 27 10:48:59 2015 
# Crontab command: */5 * * * * ~/bin/edir-procwatch.sh
# Supporting file: None
# Additional notes: 
##############################################################################
set -o nounset                              # Treat unset variables as an error
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/ndsdwatch.log"

function initlog() { 
   if [ -e /var/log/ndsdwatch.log ]
	then
		echo "log file exists" > /dev/null
	else
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo $TS $HOST $* >> ${LOG}
}
initlog

# get the pids of ndsd and ncp2nss
/bin/pidof ndsd >/tmp/ndsd.pid
/bin/pidof ncp2nss > /tmp/ncp2.pid
P1=$(cat /tmp/ndsd.pid | awk '{print $1}')
P2=$(cat /tmp/ncp2.pid | awk '{print $1}')

/usr/bin/top -b -n1 -p${P1} -p${P2} > /var/log/ndsdwatch.log

exit

