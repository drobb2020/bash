#!/bin/bash - 
#===============================================================================
#
#          FILE: remlocks.sh
# 
#         USAGE: ./remlocks.sh 
# 
#   DESCRIPTION: Automatically remove locks from packages using zypper rl
#
#                Copyright (C) 2015  David Robb
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
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Jan 27 10:15 2016
#  LAST UPDATED: Thu May 19 09:34 2016
#      REVISION: 5
#     SCRIPT ID: 055
# SSC SCRIPT ID: ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.5
sid=055                                     # personal script id number
uid=29                                      # SSC/RCMP script id number
ts=$(date +"%b %d %T")                      # general date/time stamp
ds=$(date +%a)                              # breviated day of the week, eg Mon
df=$(date +%A)                              # full day of the week, eg Monday
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/remlocks.log'                 # logging (if required)

echo "There are $(/usr/bin/zypper ll | awk 'NR > 2 { print }' | wc -l) package locks on this server."
echo "Going to remove the locks now!"
sleep 5

LR1=$(/usr/bin/zypper ll | awk 'NR > 2 { print }' | wc -l)
if [ $LR1 -ge 2 ]; then
  for x in $(/usr/bin/zypper ll | awk '{print $3}'); do /usr/bin/zypper rl $x > /dev/null 2>&1; done
else
  echo "There are no locks to remove from this server."
fi

LR2=$(/usr/bin/zypper ll | awk 'NR > 2 { print }' | wc -l)
if [ $LR2 -ge 2 ]; then
  echo "There are still some locks remaining, please investigate."
else
  echo "All locks have been removed from the packages."
fi

if [ $SENV == 1 ]; then
  . /opt/scripts/os/postinstall/postinstmenu.sh
else
  exit 1
fi

