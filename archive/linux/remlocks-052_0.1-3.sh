#!/bin/bash
REL=0.1-3
SID=052
##############################################################################
#
#    remlocks.sh - Script to automatically remove locks from packages
#                  using zypper rl
#    Copyright (C) 2015  David Robb
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#
##############################################################################
# Date Created: Tue Jan 27 10:15:28 2015 
# Last updated: 
# Crontab command: * 1 * * * root /root/bin/cifsdwatch xx user@domain.com
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
EMAIL=root

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

exit 1

