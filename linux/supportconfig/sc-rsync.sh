#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-rsync.sh
# 
#         USAGE: ./sc-rsync.sh 
# 
#   DESCRIPTION: This script is used to move new supportconfigs from servers
#                to the repository server
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
#       OPTIONS: 0 7 * * * /root/bin/sc-rsync.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Thu Jan 07 2015 14:30
#  LAST UPDATED: Sun Mar 18 2018 12:07
#       VERSION: 0.1.2
#     SCRIPT ID: 082
# SSC SCRIPT ID: 23
#===============================================================================
servers=$(cat /opt/scripts/os/servers.txt) # list of servers to rsync from from
#===============================================================================
# Go through each server in the list and collect the supportconfigs
for s in $servers 
  do
    rsync --remove-source-files -a casadmin@"$s".ross.rossdev.rcmp-grc.gc.ca:/home/sc_temp/nts* /opt/supportconf/repo/
  done

# Finished
exit 0
