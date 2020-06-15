#!/bin/bash
REL=0.01-04
##############################################################################
#
#    oes-baseline.sh - Script for baselining an OES Server pre/post tuning
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
# Date Created: Wed 21 Nov 2012 11:11:28 
# Last Updated: Mon Nov 26 13:55:53 2012 
# Company: Novell Inc.
# Crontab command: */15 * * * * /root/bin/oes-baseline.sh
# Supporting file: 
# Logfile: /var/log/baseline.log
# Additional notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare variables
TODAY=$(date +'%d-%m-%Y')
HOST=$(hostname)

# Custom variables
LOG=/var/log/oes-baseline.log
OSVER=$(cat /etc/SuSE-release | grep VERSION | cut -f 3 -d " ")
NDSBIN=/opt/novell/eDirectory/bin
NDSSBIN=/opt/novell/eDirectory/sbin
NCPSBIN=/opt/novell/ncpserv/sbin
NSSSBIN=/opt/novell/nss/sbin
DIBDIR=$($NDSBIN/ndsconfig get | grep n4u.nds.dibdir | cut -f 2 -d "=")

# Functions
addspace () { 
echo " " >> $LOG
}

# Create new log and set initial date and time
echo "--[ v$REL: baseline run at: $(date +'%A, %B, %d, %Y %k:%M:%S') ]-------" >> $LOG
addspace

# Discover the PIDs of the installed and running OES services
# top allows you to monitor up to 20 specific PIDs, feel free to add to the list
PID1=$(cat /var/opt/novell/eDirectory/data/ndsd.pid)
PID2=$(cat /var/run/novell-lum/namcd.pid)
PID3=$(cat /var/run/nscd/nscd.pid)
PID4=$(cat /var/run/slpd.pid)
PID5=$(cat /var/run/ncp2nss.pid)
PID6=$(cat /var/opt/novell/run/novell-smdrd.pid)
PID7=$(cat /var/run/httpstkd.pid)
if [ OSVER == 11 ] ;
    then
        PID8=$(cat /var/run/novell-tomcat6.pid)
    else
	PID8=$(cat /var/run/novell-tomcat5.pid)
fi
PID9=$(cat /var/lib/ntp/var/run/ntp/ntpd.pid)
PID10=$(cat /var/run/micasad.pid)
PID11=$(cat /var/run/adminusd.pid)

# Run top in batch mode and log results
top -b -n 1 -p $PID1, $PID2, $PID3, $PID4, $PID5, $PID6, $PID7, $PID8, $PID9, $PID10, $PID11 >> $LOG

# Grab NDSD thread usage
echo "--[ NDSD Thread Usage Report ]------------------------------------------------" >> $LOG
$NDSBIN/ndstrace -c threads 2>/dev/null 1>>$LOG
addspace

# Grab NCP thread usage
echo "--[ NCP Thread Usage Report ]-------------------------------------------------" >> $LOG
echo "If there is no data, the server needs to be updated to the" >> $LOG
echo "April 2011 OES Maintenance Release" >> $LOG
$NCPBIN/ncpcon "threads" 2>/dev/null 1>>$LOG
addspace

# Test disk IO for the DIB directory
echo "--[ Disk IO Performance Report for DIB directory ]----------------------------" >> $LOG
dd if=/dev/zero of=$DIBDIR/iotest.txt bs=64k count=8k conv=fdatasync 2>>$LOG
addspace

# Grab NSS Statistics
echo "--[ NSS Status and Statistics ]-----------------------------------------------" >> $LOG
echo -e 'c\nStatus\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $LOG
echo -e 'c\ncachestats\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $LOG
echo -e 'c\nSpaceInformation\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $LOG
echo -e 'c\nZLSSIOStatus\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $LOG
addspace

# Finished
exit

