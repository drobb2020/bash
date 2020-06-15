#!/bin/bash
REL=0.1-4
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
# Last updated: Thu Jul 31 13:44:49 2014 
# Crontab command: * 1 * * * root /root/bin/cifsdwatch xx user@domain.com
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG=/var/log/cifsdwatch.log

function initlog() { 
   if [ -e /var/log/cifsdwatch.log ]
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

# Get the pids for cifsd
/bin/pidof cifsd > /tmp/cifsd.pid
P1=$(cat /tmp/cifsd.pid | awk '{print $1}')
P2=$(cat /tmp/cifsd.pid | awk '{print $2}')

# Lets find oug how many conncurrent connections there are
/usr/sbin/novcifs -C > /tmp/cifsdcc.tmp
CC=$(cat /tmp/cifsdcc.tmp | awk '{print $5}')
logit "There are currently $CC concurrent connections using cifs."

# Run top in batch mode - this should be run via cron on a regular basis

/usr/bin/top -b -n1 -p${P1} -p${P2} > /tmp/topcifsd.txt
PID1=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $1}')
PID2=$(/bin/cat /tmp/topcifsd.txt | sed -n '9p' | awk '{print $1}')
PROC=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $12}')
MEMF1=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $10}')
MEM1=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $10}' | /usr/bin/cut -f 1 -d ".")
CPUF1=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $9}')
CPU1=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $9}' | /usr/bin/cut -f 1 -d ".")
MEMF2=$(/bin/cat /tmp/topcifsd.txt | sed -n '9p' | awk '{print $10}')
MEM2=$(/bin/cat /tmp/topcifsd.txt | sed -n '9p' | awk '{print $10}' | /usr/bin/cut -f 1 -d ".")
CPUF2=$(/bin/cat /tmp/topcifsd.txt | sed -n '9p' | awk '{print $9}')
CPU2=$(/bin/cat /tmp/topcifsd.txt | sed -n '8p' | awk '{print $9}' | /usr/bin/cut -f 1 -d ".")

logit "cifsd with PID $PID1 is currently consuming $MEMF1% of total memory"
logit "cifsd with PID $PID1 is currently consuming $CPUF1% of the CPU."
logit "cifsd with PID $PID2 is currently consuming $MEMF2% of total memory"
logit "cifsd with PID $PID2 is currently consuming $CPUF2% of the CPU."

function helpme() { 
	echo "The correct command line syntax is ./cifsdwatch.sh xx yy"
	echo "Where xx is the memory threshold, and yy is the cpu threshold."
	echo "for example ./cifsdwatch 20 40"
	exit 1
}

if [ $# -lt 2 ] 
    then
	echo "There are not enough arguments on the command line." > /dev/stderr
	helpme
    else
	if [ ${MEM1} -ge $1 ]
    	   then
		logit "Memory consumption on cifsd PID $PID1 is greater than $1%, sending email to $EMAIL"
		echo -e "The $PROC daemon with pid $PID1 is using $MEMF1%, this is a greater memory consumption than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High memory consumption on $HOST by cifsd" -a /tmp/topcifsd.txt $EMAIL
		logit "An e-mail alert has been sent to $EMAIL"
           else
		logit "Memory consupmtion for cifsd (PID $PID1) is in the normal range at this time"
        fi
        if [ ${MEM2} -ge $1 ]
            then
                logit "Memory consumption on cifsd PID $PID2 is greater than $1%, sending email to $EMAIL"
                echo -e "The $PROC daemon with pid $PID2 is using $MEMF2%, this is a greater memory consumption than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High memory consumption on $HOST by cifsd" -a /tmp/topcifsd.txt $EMAIL
		logit "An e-mail alert has been sent to $EMAIL"
           else
		logit "Memory consupmtion for cifsd (PID $PID2) is in the normal range at this time"
        fi
    if [ ${CPU1} -ge $2 ]
        then
	    logit "CPU consumption on cifsd PID $PID1 is greater than $2%, sending email to $EMAIL"
	    echo -e "The $PROC daemon with $PID1 is using $CPUF1%, this is a greater CPU utilization than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High CPU utilization on $HOST by cifsd" -a /tmp/topcifsd.txt $EMAIL
	    logit "An e-mail alert has been sent to $EMAIL"
        else
            logit "CPU utilization for cifsd (PID $PID1) is in the normal range at this time"
    fi
    if [ ${CPU2} -ge $2 ]
        then
	    logit "CPU consumption on cifsd PID $PID2 is greater than $2%, sending email to $EMAIL"
	    echo -e "The $PROC daemon with $PID2 is using $CPUF2%, this is a greater CPU utilization than expected with only $CC users connected.\nPlease review the attached file and do one of the following tasks:\n1) Restart the daemon\n2) Restart the server\n3) If this is a clustered resource, fail it over to another node." | mail -s "High CPU utilization on $HOST by cifsd" -a /tmp/topcifsd.txt $EMAIL
	    logit "An e-mail alert has been sent to $EMAIL"
        else
            logit "CPU utilization for cifsd (PID $PID2) is in the normal range at this time"
    fi
fi

echo "----------------------------------------" >> $LOG

exit

