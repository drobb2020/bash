#!/bin/bash - 
#===============================================================================
#
#          FILE: oes-baseline.sh
# 
#         USAGE: ./oes-baseline.sh 
# 
#   DESCRIPTION: baseline and then monitor a new OES server pre and post suggested OES tuning
#
#                Copyright (c) 2018, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: */15 * * * * /root/bin/oes-baseline.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Jul 09 2012 08:30
#  LAST UPDATED: Thu Mar 15 2018 11:09
#       VERSION: 0.2.13
#     SCRIPT ID: 049
# SSC SCRIPT ID: 00
#===============================================================================
                                      # email recipient(s)
log='/var/log/oes-baseline.log'                  # log name and location (if required)
lgr=/etc/logrotate.d/oes-baseline                # log rotation for the log
ndsbin=/opt/novell/eDirectory/bin                # path to nds binaries
ncpsbin=/opt/novell/ncpserv/sbin                 # path to supervisor ncp binaries
nsssbin=/opt/novell/nss/sbin                     # path to supervisor nss binaries
dibdir=$($ndsbin/ndsconfig get | grep n4u.nds.dibdir | cut -f 2 -d "=") # get path to the dib set
osver=$(grep VERSION /etc/SuSE-release | cut -f 2 -d "=" | sed -e 's/^[ \t]*//') # OS version
#===============================================================================

# Functions
addspace() { 
  echo "" >>$log 
}
# Create logrotate script for the new oes-baseline log
if [ -e $lgr ]; then
  echo "logrotate script exists, continuing..."
else
  echo "Creating log rotation script for oes-baseline.log"
  echo -e '/var/log/oes-baseline.log {' >> $lgr
  echo -e '\tcompress' >> $lgr
  echo -e '\tdateext' >> $lgr
  echo -e '\tmaxage 8' >> $lgr
  echo -e '\trotate 99' >> $lgr
  echo -e '\tsize=+2480k' >> $lgr
  echo -e '\tnotifempty' >> $lgr
  echo -e '\tmissingok' >> $lgr
  echo -e '\tcopytruncate' >> $lgr
  echo -e '\tpostrotate' >> $lgr
  echo -e '\t\tchmod 644 /var/log/oes-baseline.log' >> $lgr
  echo -e '\tendscript' >> $lgr
  echo -e '}' >> $lgr
  echo "Script created, continuing..."
fi

# Create new report and set date timestamp
echo "--[ OES Baseline run at: $(date +"%A, %B, %d, %Y %k:%M:%S") ]---------" >> $log
addspace

# Collect memory Statistics using free and meminfo
echo "--[ Memory Information ]--------------------------------------------------------" >> $log
/usr/bin/free -kot >> $log
addspace
/bin/cat /proc/meminfo >> $log
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
if [ "$osver" == 11 ]; 
	then 
		PID8=$(cat /var/run/novell-tomcat6.pid)
	else 
		PID8=$(cat /var/run/novell-tomcat5.pid)
fi
PID9=$(cat /var/run/httpstkd.pid)
PID10=$(cat /var/run/micasad.pid)
PID11=$(cat /var/run/adminusd.pid)

# Run top in Batch mode, but use cron to schedule, so only one iteration
echo "--[ Top Information ]-----------------------------------------------------------" >> $log
top -b -n 1 -p "$PID1", "$PID2", "$PID3", "$PID4", "$PID5", "$PID6", "$PID7", "$PID8", "$PID9", "$PID10", "$PID11" >> "$log"
addspace

# Grab NDSD thread usage
echo "--[ NDSD Thread Usage ]---------------------------------------------------------" >> $log
$ndsbin/ndstrace -c threads 2>/dev/null 1>>$log
addspace

# Report NCP thread usage
echo "--[ NCP Thread Usage ]----------------------------------------------------------" >> $log
echo "If there is no data, the server needs to be patched up to" >>$log
echo "the April 2011 OES Maintenance Release" >>$log
$ncpsbin/ncpcon "threads" 2>/dev/null 1>>$log
addspace

# Test disk IO for the DIB directory
echo "--[ DISK IO ]-------------------------------------------------------------------" >> $log
dd if=/dev/zero of="$dibdir"/iotest.txt bs=64k count=8k conv=fdatasync 2>> $log
addspace

# Grab NSS statistics
echo "--[ NSS Statistics ]------------------------------------------------------------" >> $log
echo -e 'c\nStatus\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep -v \<ESC\> >> $log
echo -e 'c\ncachestats\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep -v \<ESC\>  >> $log
echo -e 'c\nfilecachestats\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep -v \<ESC\>  >> $log
echo -e 'c\nSpaceInformation\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $log
echo -e 'c\nZLSSIOStatus\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $log
addspace

echo "--[ OES Baseline completed at: $(date +"%A, %B, %d, %Y %k:%M:%S") ]---" >> $log
addspace

# Finished
exit 0
