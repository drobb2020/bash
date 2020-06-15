#!/bin/bash
REL=0.1-1
SID=004
##############################################################################
#
#    connectionsnetstat.sh - script to count the number connections per IP
#                            address
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
# Date Created: Wed May 27 10:42:34 2015 
# Last updated: Wed May 27 10:45:09 2015 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
LOG="/tmp/connections_netstat.log"

echo $TS >>$LOG
echo "----Start Connection count per Address----" >>$LOG
echo "Number of Connection count per IP Address" >>$LOG
/bin/netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' | sort | uniq -c | sort -n |grep -v "and" |grep -v "Address" >>$LOG
echo "----END Connection count per Address----" >>$LOG
echo "----Total Number of TCP/UDP Connections----" >>$LOG
/bin/netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' |grep -v "and" |grep -v "Address"|wc -l >>$LOG
echo "----END Total Connection Count----" >>$LOG

exit 1

