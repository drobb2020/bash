#!/bin/bash
REL=0.01-02
##############################################################################
#
#    ndsd-mon.sh - Monitor and restart nds if it crashes
#    Copyright (C) 2012  David Robb
#
##############################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
# Date Created: Thu Apr 12 14:48:47 2012 
# Last updated: Fri Apr 13 20:09:08 2012 
# Crontab command: */5 * * * * /root/bin/ndsd-mon.sh
# Supporting file: None
##############################################################################
DTSTAMP=$(date +"%b %d %T")
LOGFILE="/var/log/ndsdmon.log"

 /usr/sbin/rcndsd status &>/dev/null
 returnCode=$?

echo "$DTSTAMP Return Code: $returnCode" >> $LOGFILE

if [ $returnCode == "0" ]; then
 echo -e "$DTSTAMP NDSD service running" | tee -a $LOGFILE

else
 # printf "eDirectory is not running on server: $(cat /etc/opt/novell/eDirectory/conf/nds.conf | grep 'n4u.nds.server-name' | cut -d= -f2)" | mail -s "eDirectory is DOWN" @txt.att.net
 # printf "eDirectory is not running on server: $(cat /etc/opt/novell/eDirectory/conf/nds.conf | grep 'n4u.nds.server-name' | cut -d= -f2)" | mail -s "eDirectory is DOWN"  echo "NDSD service NOT running, attempting restart now" | tee -a $LOGFILE
 /usr/sbin/rcndsd restart
 echo "$DTSTAMP NDSD restart attempt complete"| tee -a $LOGFILE
 /usr/sbin/rcnamcd restart
 echo "$DTSTAMP NAMCD (LUM) restarted after NDSD restart" | tee -a $LOGFILE
 fi
 echo "--------------------------------------------------------" >> $LOGFILE

# Finished
exit

