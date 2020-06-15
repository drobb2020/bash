#!/bin/bash
#===============================================================================
#
#          FILE: smt-mirror.sh
# 
#         USAGE: ./smt-mirror.sh 
# 
#   DESCRIPTION: Script to mirror all configured repositories from NCC or SCC
#
#                Copyright (C) 2016  David Robb
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENts: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: 
#  LAST UPDATED: Fri Nov 11 2016 10:05
#       VERSION: 3
#     SCRIPT ID: ---
# SSC UNIQUE ID: 00
#===============================================================================
version=0.1.3                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/smt-mirror.log'                   # logging (if required)
version=0.1.2
# Script to mirror all configured repositories 

/usr/sbin/smt-mirror

# Completion message
echo ""
echo "---------------------------------------------------------------------"
echo "SMT Updated - Repositories mirrored from NCC"
echo "---------------------------------------------------------------------"
echo "All configured repositories have been mirrored down from NCC, and"
echo "timestamped. Servers can now be patched to the latest releases."
echo "---------------------------------------------------------------------"
echo "Have fun patching ..."
echo ""

exit 1

