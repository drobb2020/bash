#!/bin/bash
REL=0.1-6
SID=008
##############################################################################
#
#    memwatch.sh - Script to monitor high memory utilization
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
# Date Created: Wed Dec 12 09:00:00 2012
# Last updated: Wed May 27 11:31:51 2015 
# Crontab command: * 1 * * * root /root/bin/memwatch xx user@domain.com
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
LOG=/var/log/memwatch.log

function initlog() { 
   if [ -e /var/log/memwatch.log ]
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

# Run top in batch mode - this should be run via cron on a regular basis

/usr/bin/top -b -n1 > /tmp/topmem.txt

PROC=$(/bin/cat /tmp/topmem.txt | sed -n '8p' | awk '{print $12}')
MEMF=$(/bin/cat /tmp/topmem.txt | sed -n '8p' | awk '{print $10}')
MEM=$(/bin/cat /tmp/topmem.txt | sed -n '8p' | awk '{print $10}' | /usr/bin/cut -f 1 -d ".")

logit "The current highest memory consumer is $PROC, and it is using $MEMF% of total memory"

function helpme() { 
  echo "WARNING"
  echo "-------------------------------------------------------------------"
  echo "The correct command line syntax is ./memwatch.sh xx user@domain.com"
  echo "for example ./memwatch 65 drobb@novell.com"
  echo "Where 65 is the high limit of memory utilization you want to see"
  echo "==================================================================="
  exit 1
}

if [ $# -lt 2 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
    helpme
  else
    if [ ${MEM} -ge $1 ]; then
      logit "Memory consumption is greater than $1%, sending email to $2"
      echo "Memory consumption is greater than $1%, sending email to $2"
      echo -e "The daemon $PROC is using $MEMF%, more memory than expected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server" | mail -s "High memory utilization on $HOST" -a /tmp/topmem.txt $2
      logit "An e-mail alert has been sent to $2"
    else
      logit "Memory is normal at this time"
    fi
fi

echo "-----------------------------------------------------------------------------------------------------------" >> $LOG

exit 1

