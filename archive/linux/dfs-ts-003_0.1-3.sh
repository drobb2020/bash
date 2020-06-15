#!/bin/bash
REL=0.1-3
SID=003
##############################################################################
#
#    dfs-ts.sh - script to troubleshoot DFS
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
# Last updated: Wed May 27 09:40:11 2015 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
LOG="/tmp/dfs-gstack.log"

# Delete old log if it exists
if [ -f /tmp/dfs-gstack.log ]; then
  rm -f /tmp/dfs-gstack.log
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
echo "--[ Process State ]--------------------------------------------------" >> $LOG
echo "Process State of VLDB" >> $LOG
/bin/ps aux | grep  $VPID | grep -v grep >> $LOG
echo "Process State of jstcpd (first PID)" >> $LOG
/bin/ps aux | grep $JPID1 | grep -v grep >> $LOG
echo "Process State of jstcpd (second PID)" >> $LOG
/bin/ps aux | grep $JPID2 | grep -v grep >> $LOG
echo "Process State of adminusd" >> $LOG
/bin/ps aux | grep $APID | grep -v grep >> $LOG
echo "Process State of ndsd" >> $LOG
/bin/ps aux | grep $NPID | grep -v grep >> $LOG
echo "=====================================================================" >> $LOG
# Get the thread usage for NDS and NCP
echo "--[ NDS & NCP Thread Stats ]-----------------------------------------" >> $LOG
echo "NDS Thread Usage"
/opt/novell/eDirectory/bin/ndstrace -c threads >> $LOG
echo " "
echo "NCP Thread Usage"
/sbin/ncpcon threads >> $LOG
echo "=====================================================================" >> $LOG
# Get a gstack trace of each process
echo "--[ Gstack Trace ]---------------------------------------------------" >> $LOG
echo "Capture started at $TS" >> $LOG
echo "--[ Gstack of VLDB ]-------------------------------------------------" >> $LOG
/usr/bin/gstack $VPID >> $LOG
echo "--[ Gstack of jstcpd (first PID) ]-----------------------------------" >> $LOG
/usr/bin/gstack $JPID1 >> $LOG
echo "--[ Gstack of jstcpd (second PID) ]----------------------------------" >> $LOG
/usr/bin/gstack $JPID2 >> $LOG
echo "--[ Gstack of adminusd ]---------------------------------------------" >> $LOG
/usr/bin/gstack $APID >> $LOG
echo "--[ Gstack of ndsd ]-------------------------------------------------" >> $LOG
/usr/bin/gstack $NPID >> $LOG
echo "=====================================================================" >> $LOG
echo "Report finished at $TS on $HOST" >> $LOG

# Cleanup tmp files
rm -f /tmp/*.pid.$$

# Finished
exit 1

