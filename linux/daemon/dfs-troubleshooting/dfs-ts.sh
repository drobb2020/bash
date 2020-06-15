#!/bin/bash - 
#===============================================================================
#
#          FILE: dfs-ts.sh
# 
#         USAGE: ./dfs-ts.sh 
# 
#   DESCRIPTION: Script to troubleshoot DFS utilization
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
#   LAST UDATED: Mon Mar 12 2018 07:57
#       VERSION: 0.1.6
#     SCRIPT ID: 004
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.6                                    # version number of the script
sid=004                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=dfs-troubleshooting                        # email sender
email=root                                       # email recipient(s)
log='/var/log/dfs-ts.log'                        # log name and location (if required)
#===============================================================================

# Delete old log if it exists
if [ -f $log ]; then
  rm -f $log
fi

# Get the pids of the following processes: vldb, jstcp, adminusd, and ndsd
/sbin/pidof vldb > /tmp/vldb.pid.$$
/sbin/pidof jstcpd > /tmp/jstcpd.pid.$$
/sbin/pidof adminusd > /tmp/adminusd.pid.$$
/sbin/pidof ndsd > /tmp/ndsd.pid.$$

VPID=$(cat /tmp/vldb.pid.$$)
JPID1=$(cat /tmp/jstcpd.pid.$$ | awk '{print $1}')
JPID2=$(cat /tmp/jstcpd.pid.$$ | awk '{print $2}')
APID=$(cat /tmp/adminusd.pid.$$)
NPID=$(cat /tmp/ndsd.pid.$$)

# Check the state of each process to see if one is hung
echo "--[ Process State ]--------------------------------------------------" >> $log
echo "Process State of VLDB" >> $log
/bin/ps aux | grep  $VPID | grep -v grep >> $log
echo "Process State of jstcpd (first PID)" >> $log
/bin/ps aux | grep $JPID1 | grep -v grep >> $log
echo "Process State of jstcpd (second PID)" >> $log
/bin/ps aux | grep $JPID2 | grep -v grep >> $log
echo "Process State of adminusd" >> $log
/bin/ps aux | grep $APID | grep -v grep >> $log
echo "Process State of ndsd" >> $LOG
/bin/ps aux | grep $NPID | grep -v grep >> $LOG
echo "=====================================================================" >> $log
# Get the thread usage for NDS and NCP
echo "--[ NDS & NCP Thread Stats ]-----------------------------------------" >> $log
echo "NDS Thread Usage"
/opt/novell/eDirectory/bin/ndstrace -c threads >> $log
echo " "
echo "NCP Thread Usage"
/sbin/ncpcon threads >> $log
echo "=====================================================================" >> $log
# Get a gstack trace of each process
echo "--[ Gstack Trace ]---------------------------------------------------" >> $log
echo "Capture started at $ts" >> $log
echo "--[ Gstack of VLDB ]-------------------------------------------------" >> $log
/usr/bin/gstack $VPID >> $log
echo "--[ Gstack of jstcpd (first PID) ]-----------------------------------" >> $log
/usr/bin/gstack $JPID1 >> $log
echo "--[ Gstack of jstcpd (second PID) ]----------------------------------" >> $log
/usr/bin/gstack $JPID2 >> $log
echo "--[ Gstack of adminusd ]---------------------------------------------" >> $log
/usr/bin/gstack $APID >> $log
echo "--[ Gstack of ndsd ]-------------------------------------------------" >> $log
/usr/bin/gstack $NPID >> $log
echo "=====================================================================" >> $log
echo "Report finished at $ts on $host" >> $log

# Cleanup tmp files
rm -f /tmp/*.pid.$$

# Finished
exit 1

