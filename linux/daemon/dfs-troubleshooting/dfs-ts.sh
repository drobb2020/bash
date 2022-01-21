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
#  LAST UPDATED: Mon Mar 12 2018 07:57
#       VERSION: 0.1.6
#     SCRIPT ID: 004
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
log='/var/log/dfs-ts.log'                        # log name and location (if required)
#===============================================================================
# Delete old log if it exists
if [ -f "$log" ]; then
  rm -rf "$log"
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
echo "--[ Process State ]--------------------------------------------------";
echo "Process State of VLDB";
/bin/ps aux | grep  "$VPID" | grep -v grep;
echo "Process State of jstcpd (first PID)";
/bin/ps aux | grep "$JPID1" | grep -v grep;
echo "Process State of jstcpd (second PID)";
/bin/ps aux | grep "$JPID2" | grep -v grep;
echo "Process State of adminusd";
/bin/ps aux | grep "$APID" | grep -v grep;
echo "Process State of ndsd";
/bin/ps aux | grep "$NPID" | grep -v grep;
echo "=====================================================================";
echo "";
# Get the thread usage for NDS and NCP
echo "--[ NDS & NCP Thread Stats ]-----------------------------------------";
echo "NDS Thread Usage";
/opt/novell/eDirectory/bin/ndstrace -c threads;
echo " ";
echo "NCP Thread Usage";
/sbin/ncpcon threads;
echo "=====================================================================";
echo "";
# Get a gstack trace of each process
echo "--[ Gstack Trace ]---------------------------------------------------";
echo "Capture started at $ts";
echo "--[ Gstack of VLDB ]-------------------------------------------------";
/usr/bin/gstack "$VPID";
echo "--[ Gstack of jstcpd (first PID) ]-----------------------------------";
/usr/bin/gstack "$JPID1";
echo "--[ Gstack of jstcpd (second PID) ]----------------------------------";
/usr/bin/gstack "$JPID2";
echo "--[ Gstack of adminusd ]---------------------------------------------";
/usr/bin/gstack "$APID";
echo "--[ Gstack of ndsd ]-------------------------------------------------";
/usr/bin/gstack "$NPID";
echo "=====================================================================";
echo "Report finished at $ts on $host" >> "$log"

# Cleanup tmp files
rm -f /tmp/*.pid.$$

# Finished
exit 0
