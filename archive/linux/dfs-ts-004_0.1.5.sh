#!/bin/bash - 
#===============================================================================
#
#          FILE: dfs-ts.sh
# 
#         USAGE: ./dfs-ts.sh 
# 
#   DESCRIPTION: Script to troubleshoot DFS utilization
#
#                Copyright (C) 2016  David Robb
#
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Mar 03 2015 11:44
#  LAST UPDATED: Thu Jun 16 2016 07:29
#      REVISION: 4
#     SCRIPT ID: 004
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.5
sid=004                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/dfs-ts.log'                       # logging (if required)

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

