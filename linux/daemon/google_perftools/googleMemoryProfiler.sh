#!/bin/bash - 
#===============================================================================
#
#          FILE: googleMemoryProfiler.sh
# 
#         USAGE: ./googleMemoryProfiler.sh 
# 
#   DESCRIPTION: This script will remove heap files created by google profiler 
#                older than 1 minute so it does not fill up the disk space with
#                heap files
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
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Mar 03 2015 11:44
#   LAST UDATED: Mon Mar 12 2018 08:07
#       VERSION: 0.1.4
#     SCRIPT ID: 007
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.4                                    # version number of the script
sid=007                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=google-profiler                            # email sender
email=root                                       # email recipient(s)
log='/var/log/googleMemoryProfiler.log'          # log name and location (if required)
OF=/tmp/googleMemoryProfiler.txt
OUTPUT="Have executed the removal of all heap files older than 15 minute"
LOCATION=/tmp
FILENAMES=heap*
PATHTOCONF="/etc/opt/novell/eDirectory/conf/nds.conf"
VARDIR=`/bin/cat $PATHTOCONF |grep -i vardir |awk 'BEGIN {FS="="} {print $2}'`
NDSDPID=`/bin/cat $VARDIR/ndsd.pid`
#===============================================================================

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

