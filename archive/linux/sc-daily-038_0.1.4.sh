#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-daily.sh
# 
#         USAGE: ./sc-daily.sh 
# 
#   DESCRIPTION: Create a daily supportconfig
#
#                Copyright (C) 2015  David Robb
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
#       OPTIONS: 30 1 * * * /root/bin/sc-daily.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: This script is out of date and very rudimentary
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Oct 02 2012 14:30
#  LAST UPDATED: Tue Jul 21 2015 10:24
#      REVISION: 4
#     SCRIPT ID: 038
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.4
sid=038                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/sc-daily.log'                 # logging (if required)
ds=$(date +%a)                              # Abreviated day of the week
df=$(date +%A)                              # Full day of the week

# Create Directory structure if it doesn't exist
if [ -d /backup/supportconfig/$host/$ds ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/supportconfig/$host/$ds
fi

# Remove any old supportconfig
if [ -d /backup/supportconfig/$host/$ds ]; then
  /bin/rm -r /backup/supportconfig/$host/$ds/* 1>2 /dev/null
fi

# Run supportconfig quietly
/sbin/supportconfig -QR /backup/supportconfig/$host/$ds

#Finished
exit 1

