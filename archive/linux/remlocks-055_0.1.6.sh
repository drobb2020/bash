#!/bin/bash - 
#===============================================================================
#
#          FILE: remlocks.sh
# 
#         USAGE: ./remlocks.sh 
# 
#   DESCRIPTION: Script to automatically remove locks from packages using zypper rl
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
#       CREATED: Tue Jan 27 2015 10:15 
#  LAST UPDATED: Tue Jun 07 2016 15:50
#      REVISION: 6
#     SCRIPT ID: 055
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.6                                   # version number of the script
sid=052                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/remlocks.log'                     # logging (if required)

echo -e "---------------------------------------------------"
echo -e "Locks are only useful if you set them yourself!"
echo -e "==================================================="
llResults=$(zypper ll)
llExpected='There are no package locks defined.'

if [[ "$llResults" == "$llExpected" ]]; then
  echo "$llResults"
  echo "Have Fun patching."
else
  locks=$(zypper ll | tail -1 | awk '{print $1}')
  if [ ${locks} -ge 1 ]; then
    echo "There are $locks package locks on this server."
    read -r -p "Want to remove all locks now? [y/n] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo ""
      for x in $(zypper ll | awk '{print $3}'); do zypper rl $x > /dev/null 2>&1; done
      echo "All locks have been removed from the server."
      echo "Happy Patching!"
    fi
  fi
fi

exit 1

