#!/bin/bash - 
#===============================================================================
#
#          FILE: test2.sh
# 
#         USAGE: ./test2.sh 
# 
#   DESCRIPTION: 
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
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: Thu Sep 01 2016 08:04
#  LAST UPDATED: Thu Sep 01 2016 08:04
#       VERSION: -
#     SCRIPT ID: ---
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.0                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/test2.sh.log'                   # logging (if required)

# Set n to 1
n=1

# Continue until $n equals 5
while [ $n -le 5 ]
do
	echo "Welcome $n times."
	sleep 10
	n=$(( n+1 )) # increment $n by 1
done

exit 1

