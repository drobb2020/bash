#!/bin/bash
REL=0.1-1
##############################################################################
#
#    cifsdwatch.sh - Script to monitor high memory utilization
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
# Date Created: Wed Jul 30 09:52:07 2014 
# Last updated: Wed Jul 30 10:19:30 2014 
# Crontab command: * 1 * * * root /root/bin/cifsdwatch xx user@domain.com
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
		echo "log file exists"
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

# Get the pids for cifsd
/bin/pidof cifsd > /tmp/cifsd.pid
P1=$(cat /tmp/cifsd.pid | awk '{print $1}')
P2=$(cat /tmp/cifsd.pid | awk '{print $2}')

# Run top in batch mode - this should be run via cron on a regular basis

/usr/bin/top -b -n1 -p($P1) -p($P2) > /tmp/topcifsd.txt

PROC=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | /usr/bin/cut -f 23 -d " ")
MEMF=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | /usr/bin/cut -f 19 -d " ")
MEM=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | /usr/bin/cut -f 19 -d " " | /usr/bin/cut -f 1 -d ".")
CPUF=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | /usr/bin/cut -f 17 -d " ")
CPU=$(/bin/cat .tmp/topcifsd.txt | sed -n '8p' | /usr/bin/cut -f 17 -d " " | /usr/bin/cut -f 1 -d ".")

logit "cifsd is currently consuming $MEMF% of total memory"
logit "cifsd is currently consuming $CPUF% of the CPU."

function helpme() { 
	echo "The correct command line syntax is ./cifsdwatch.sh xx yy user@domain.com"
	echo "Where xx is the memory threshold, and yy is the cpu threshold."
	echo "for example ./cifsdwatch 65  50 drobb@novell.com"
	exit 1
}

if [ $# -lt 3 ] 
    then
	echo "There are not enough arguments on the command line." > /dev/stderr
	helpme
    else
	if [ ${MEM} -ge $1 ]
    	   then
		logit "Memory consumption is greater than $1%, sending email to $3"
		echo "Memory consumption is greater than $1%, sending email to $3"
		echo -e "The daemon $PROC is using $MEMF%, this is more memory than expected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server" | mail -s "High memory utilization on $HOST" -a /tmp/topmem.txt $3
		logit "An e-mail alert has been sent to $3"
           else
		logit "Memory consupmtion for cifsd is normal at this time"
        fi
    if [ ${CPU} -ge $2 ]
        then
	    logit "CPU consumption is greater than $2%, sending email to $3"
            echo "Memory consumption is greater than $2%, sending email to $3"
	    echo -e "The daemon $PROC is using $MEMF%, this is more memory than expected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server" | mail -s "High memory utilization on $HOST" -a /tmp/topmem.txt $3
	    logit "An e-mail alert has been sent to $3"
        else
            logit "CPU utilization for cifsd is normal at this time"
    fi
fi

echo "-----------------------------------------------------------------------------------------------------------" >> $LOG

exit

