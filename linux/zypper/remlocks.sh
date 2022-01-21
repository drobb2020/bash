#!/bin/bash - 
#===============================================================================
#
#          FILE: remlocks.sh
# 
#         USAGE: ./remlocks.sh 
# 
#   DESCRIPTION: automatically remove locks from packages using zypper rl
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
#       CREATED: Tue Jan 27 2015 10:15
#  LAST UPDATED: Sun Mar 18 2018 13:34
#       VERSION: 0.1.7
#     SCRIPT ID: 055
# SSC SCRIPT ID: 00
#===============================================================================
# general message
echo -e "---------------------------------------------------"
echo -e "Locks are only useful if you set them yourself!"
echo -e "==================================================="
llResults=$(zypper ll)
llExpected='There are no package locks defined.'

# Check for locks and remove them if present.
if [[ "$llResults" == "$llExpected" ]]; then
  echo "$llResults"
  echo "Have Fun patching."
else
  locks=$(zypper ll | tail -1 | awk '{print $1}')
  if [ "${locks}" -ge 1 ]; then
    echo "There are $locks package locks on this server."
    read -r -p "Want to remove all locks now? [y/n] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo ""
      for x in $(zypper ll | awk '{print $3}'); do zypper rl "$x" > /dev/null 2>&1; done
      echo "All locks have been removed from the server."
      echo "Happy Patching!"
    fi
  fi
fi

# Finished
exit 0
