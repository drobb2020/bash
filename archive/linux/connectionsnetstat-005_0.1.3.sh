#!/bin/bash - 
#===============================================================================
#
#          FILE: connectionsnetstat.sh
# 
#         USAGE: ./connectionsnetstat.sh 
# 
#   DESCRIPTION: Script to count the number connections per IP Address on OES
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
#       CREATED: Wed May 27 2015 10:42
#  LAST UPDATED: Thu Jun 16 2016 07:33
#      REVISION: 2
#     SCRIPT ID: 005
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.3
sid=005                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/connectionsnetstat.log'           # logging (if required)

echo $ts >>$log

echo "----Start Connection count per Address----" >>$log
echo "Number of Connection count per IP Address" >>$log
/bin/netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' | sort | uniq -c | sort -n |grep -v "and" |grep -v "Address" >>$log
echo "----END Connection count per Address----" >>$log

echo "----Total Number of TCP/UDP Connections----" >>$log
/bin/netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' |grep -v "and" |grep -v "Address"|wc -l >>$log
echo "----END Total Connection Count----" >>$log

exit 1

