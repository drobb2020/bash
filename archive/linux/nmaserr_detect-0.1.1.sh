#!/bin/bash - 
#===============================================================================
#
#          FILE: nmaserr_detect.sh
# 
#         USAGE: ./nmaserr_detect.sh 
# 
#   DESCRIPTION: Script to configure an OES server to write application cores to 
#                a specifc location and with a particular file name
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
#       CREATED: Fri Jan 08 08:41:30 2016 
#  LAST UPDATED: Fri Jan 08 09:12:30 2016
#      REVISION: 1
#     SCRIPT ID: ---
# SSC UNIQUE ID: ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
version=0.1.1                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # user checking routine
email=calvin.hamilton@rcmp-grc.gc.ca,david.robb@rcmp-grc.gc.ca   # default email value
log='/var/log/nmaserr_detect.log'               # logging (if required)
mlog='/var/log/messages'                        # path to messages log

# tail the current messages log 
/usr/bin/tail $mlog > /tmp/nmaserr_detect

# Cat the log extract and and see if we hava NMAS error -1660
/bin/cat /tmp/nmaserr_detect | grep "NMAS has returned Error\:-1660" > /tmp/errdet.1660
if [ -n "$(/bin/cat /tmp/errdet.1660)" ]; then
  if [ -n "$email" ]; then
    echo "NMAS error -1660 has been detected on $host. Users are not authenticating and have lost access to their data. Please connect to the server and check the status of the novell-cifs daemon (cifsd). It will probably require a restart." | mail -s "NMAS Error -1660 Detected on $host" -a /tmp/errdet.1660 $email
  fi
else
  echo "NMAS appears to be healthy" > /dev/null
fi

# Cleanup
rm -f /tmp/nmaserr_detect
rm -f /tmp/errdet.1660

exit 1

