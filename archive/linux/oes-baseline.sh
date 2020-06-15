#!/bin/bash
REL=0.01-04
##############################################################################
#
#    oes-baseline.sh - a script to baseline and monitor OES services pre and 
#                      post tuning
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
# Date Created: Monday July 09 2012 
# Last Updated: Mon Jul 09 13:04:15 EDT 2012  
# Company: Novell Inc.
# Crontab command: * */10 * * * /root/bin/oes-baseline.sh
# Supporting file: N/A
# Additional notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare variables
TODAY=$(date +"%d-%m-%Y")
HOST=$(hostname)

# Custom Variables
REPDIR=/var/log/top
REPNAME=OES_Baseline_Report
EMAIL=edirreports@excession.org
HT=$HOST-$TODAY
REPORT=$REPDIR/$REPNAME-from-$HT.txt
OSVER=$(cat /etc/SuSE-release | grep VERSION | cut -d " " -f 3)

# Functions
addspace() { echo "" >>$REPORT 
}

# Create new report and set date timestamp
echo "--[ Baseline run at: $(date +"%A, %B, %d, %Y %k:%M:%S") ]------------------------" >> $REPORT
addspace

# Collect memory Statistics using vmstat
echo "--[ vmstat memory ]---------------------------------" >> $REPORT
vmstat 1 4 >> $REPORT
addspace

# Collect the PID's of the OES services to monitor
# top allows you to monitor up to 20 specific PID's, feel free to add
PID1=$(cat /var/opt/novell/eDirectory/data/ndsd.pid)
PID2=$(cat /var/run/novell-lum/namcd.pid)
PID3=$(cat /var/run/nscd/nscd.pid)
PID4=$(cat /var/run/slpd.pid)
PID5=$(cat /var/run/ncp2nss.pid)
PID6=$(cat /var/opt/novell/run/novell-smdrd.pid)
if [ $OSVER == 11 ]; 
	then 
		PID7=$(cat /var/run/novell-tomcat6.pid)
	else 
		PID7=$(cat /var/run/novell-tomcat5.pid)
fi
PID8=$(cat /var/run/httpstkd.pid)

# Run top in Batch mode, but use cron to schedule, so only one iteration
echo "--[ Top Information ]----------------------------------" >> $REPORT
top -b -n 1 -p $PID1, $PID2, $PID3, $PID4, $PID5, $PID6, $PID7, $PID8 >> $REPORT
addspace

# Finished
exit

