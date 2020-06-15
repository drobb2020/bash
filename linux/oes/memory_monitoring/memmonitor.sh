#!/bin/bash - 
#===============================================================================
#
#          FILE: memmonitor.sh
# 
#         USAGE: ./memmonitor.sh 
#
#   DESCRIPTION: Monitor process memory utilization on OES2015 SP1
#
#                Copyright (c) 2017, David Robb
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
#       OPTIONS: */10 * * * * /root/bin/memmonitor.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Sat Jan 14 2017 09:00
#  LAST UPDATED: Sun Jan 15 2017 07:41
#       VERSION: 1
#     SCRIPT ID: 000
# SSC UNIQUE ID: 00
#===============================================================================
version=0.1.1                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC|RCMP script id number
#===============================================================================
ts=$(date +"%b %d %T")                          # general date|time stamp
ds=$(date +%a)                                  # short day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
date=$(date)                                    # standard date string
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=                                          # email recipient(s)
log='/var/log/memmonitor.log'                   # logging (if required)
#===============================================================================

echo "" >> /root/${host}_memory_monitor.txt
echo "------------------------------------------------------------" >> /root/${host}_memory_monitor.txt
echo "Process Memory Monitor" >> /root/${host}_memory_monitor.txt
echo "------------------------------------------------------------" >> /root/${host}_memory_monitor.txt
echo "Collection started at: $date" >> /root/${host}_memory_monitor.txt
echo "" >> /root/${host}_memory_monitor.txt
/bin/ps axwwo user,pid,ppid,%cpu,%mem,vsz,rss,stat,time,cmd >> /root/${host}_memory_monitor.txt

exit 1

