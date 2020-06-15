#!/bin/bash
REL=0.1-09
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
# Date Created: Mon Jul 09 08:30;00 2012 
# Last Updated: Tue Dec 18 12:08:00 2012 
# Company: Novell Inc.
# Crontab command: */15 * * * * /root/bin/oes-baseline.sh
# Supporting file: N/A
# Additional notes: Don't forget to set the custom variables for your environment.
##############################################################################
# Declare variables
TODAY=$(date +"%d-%m-%Y")
HOST=$(hostname)

# Custom Variables
LOG=/var/log/oes-baseline.log
LGR=/etc/logrotate.d/oes-baseline
OSVER=$(cat /etc/SuSE-release | grep VERSION | cut -d " " -f 3)
NDSBIN=/opt/novell/eDirectory/bin
NDSSBIN=/opt/novell/eDirectory/sbin
NCPSBIN=/opt/novell/ncpserv/sbin
NSSSBIN=/opt/novell/nss/sbin
DIBDIR=$($NDSBIN/ndsconfig get | grep n4u.nds.dibdir | cut -f 2 -d "=")

# Functions
addspace() { echo "" >>$LOG 
}
# Create logrotate scipt for the new oes-baseline log
if [ -e $LGR ]
then
	echo "logrotate script exists, continuing..."
else
	echo "Creating log rotation script for oes-baseline.log"
	echo -e '/var/log/oes-baseline.log {' >> $LGR
	echo -e '\tcompress' >> $LGR
	echo -e '\tdateext' >> $LGR
	echo -e '\tmaxage 8' >> $LGR
	echo -e '\trotate 99' >> $LGR
	echo -e '\tsize=+2480k' >> $LGR
	echo -e '\tnotifempty' >> $LGR
	echo -e '\tmissingok' >> $LGR
	echo -e '\tcopytruncate' >> $LGR
	echo -e '\tpostrotate' >> $LGR
	echo -e '\t\tchmod 644 /var/log/oes-baseline.log' >> $LGR
	echo -e '\tendscript' >> $LGR
	echo -e '}' >> $LGR
	echo "Script created, continuing..."
fi

# Create new report and set date timestamp
echo "--[ v$REL OES Baseline run at: $(date +"%A, %B, %d, %Y %k:%M:%S") ]---------" >> $LOG
addspace

# Collect memory Statistics using free and meminfo
echo "--[ Memory Information ]--------------------------------------------------------" >> $LOG
/usr/bin/free -kot >> $LOG
addspace
/bin/cat /proc/meminfo >> $LOG
addspace

# Collect the PID's of the OES services to monitor
# top allows you to monitor up to 20 specific PID's, feel free to add
PID1=$(cat /var/opt/novell/eDirectory/data/ndsd.pid)
PID2=$(cat /var/run/novell-lum/namcd.pid)
PID3=$(cat /var/run/nscd/nscd.pid)
PID4=$(cat /var/run/slpd.pid)
PID5=$(cat /var/run/ncp2nss.pid)
PID6=$(cat /var/opt/novell/run/novell-smdrd.pid)
PID7=$(cat /var/run/httpstkd.pid)
if [ $OSVER == 11 ]; 
	then 
		PID8=$(cat /var/run/novell-tomcat6.pid)
	else 
		PID8=$(cat /var/run/novell-tomcat5.pid)
fi
PID9=$(cat /var/run/httpstkd.pid)
PID10=$(cat /var/run/micasad.pid)
PID11=$(cat /var/run/adminusd.pid)

# Run top in Batch mode, but use cron to schedule, so only one iteration
echo "--[ Top Information ]-----------------------------------------------------------" >> $LOG
top -b -n 1 -p $PID1, $PID2, $PID3, $PID4, $PID5, $PID6, $PID7, $PID8, $PID9, $PID10, $PID11 >> $LOG
addspace

# Grab NDSD thread usaga
echo "--[ NDSD Thread Usage ]---------------------------------------------------------" >> $LOG
$NDSBIN/ndstrace -c threads 2>/dev/null 1>>$LOG
addspace

# Grap NCP thread usage
echo "--[ NCP Thread Usage ]----------------------------------------------------------" >> $LOG
echo "If there is no data, the server needs to be patched up to" >>$LOG
echo "the April 2011 OES Maintenance Release" >>$LOG
$NCPSBIN/ncpcon "threads" 2>/dev/null 1>>$LOG
addspace

# Test disk IO for the DIB directory
echo "--[ DISK IO ]-------------------------------------------------------------------" >> $LOG
dd if=/dev/zero of=$DIBDIR/iotest.txt bs=64k count=8k conv=fdatasync 2>>$LOG
addspace

# Grab NSS statistics
echo "--[ NSS Statistics ]------------------------------------------------------------" >> $LOG
echo -e 'c\nStatus\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep -v \<ESC\> >> $LOG
echo -e 'c\ncachestats\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep -v \<ESC\>  >> $LOG
echo -e 'c\nfilecachestats\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep -v \<ESC\>  >> $LOG
echo -e 'c\nSpaceInformation\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $LOG
echo -e 'c\nZLSSIOStatus\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $LOG
addspace

echo "--[ v$REL OES Baseline completed at: $(date +"%A, %B, %d, %Y %k:%M:%S") ]---" >> $LOG
addspace

# Finished
exit
