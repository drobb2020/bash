#!/bin/bash - 
#===============================================================================
#
#          FILE: zombie.sh
# 
#         USAGE: ./zombie.sh 
# 
#   DESCRIPTION: Log whenever ndpapp goes into a zombie state
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
#       CREATED: Tue Nov 03 2015 03:50
#  LAST UPDATED: Tue Mar 13 2018 08:28
#       VERSION: 0.1.3
#     SCRIPT ID: 018
# SSC SCRIPT ID: 00
#===============================================================================
# check to see if ndpapp is a zombie (this is actually normal behavior for this daemon)
while true
do
  date +"%T:%N" >> /root/zombie_ndpapp-debug5.log
  pgrep -E 'Z' | grep ndpapp | grep -v grep >> /root/zombie_ndpapp-debug5.log
  sleep 1
done

# Finished
exit 0
