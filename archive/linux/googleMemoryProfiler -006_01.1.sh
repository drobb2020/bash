 #! /bin/bash
REL=0.1-1
SID=006
##############################################################################
#
#    googleMemoryProfiler.sh - this script will remove heap files created by 
#                              google profiler older than 1 minute so it does
#                              not fill up the disk space with heap files
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
# Last updated: Wed May 27 11:20:28 2015 
# Crontab command: */10 * * * * ~/bin/googleMemoryProfiler.sh
# Supporting file: None
# Additional notes: 
##############################################################################
OF=/tmp/googleMemoryProfiler.txt
OUTPUT="Have executed the removal of all heap files older than 15 minute"
LOCATION=/tmp
FILENAMES=heap*
PATHTOCONF="/etc/opt/novell/eDirectory/conf/nds.conf"
VARDIR=`/bin/cat $PATHTOCONF |grep -i vardir |awk 'BEGIN {FS="="} {print $2}'`
NDSDPID=`/bin/cat $VARDIR/ndsd.pid`
#echo $PATHTOCONF
#echo $VARDIR
#echo $NDSDPID
/bin/date >>$OF
/usr/bin/find /$LOCATION/$FILENAMES -mmin +1 -exec rm {} \;
echo $OUTPUT >>$OF
echo "#####TOP#####">>$OF
/usr/bin/top -b -n1 -p $NDSDPID >>$OF
echo "#####FREE#####">>$OF
/usr/bin/free -m >>$OF
echo "#####/proc/meminfo######" >>$OF
/bin/cat /proc/meminfo >>$OF
for i in `/bin/ls $LOCATION/$FILENAMES`; do
echo "##########">>$OF
/bin/ls -gG $i>>$OF
echo "##########">>$OF
/usr/bin/pprof --text /opt/novell/eDirectory/sbin/ndsd $i>>$OF
done 

exit 1

