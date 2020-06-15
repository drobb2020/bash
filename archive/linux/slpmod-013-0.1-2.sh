#!/bin/bash
REL=0.1-2
SID=013
##############################################################################
#
#    slpmod.sh - A script to modify the slp.conf file on a server to include
#                a new scope name
#    Copyright (C) 2013  David Robb
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
# Date Created: Mon Jan 07 14:54:48 2013 
# Last updated: Wed May 27 11:53:37 2015 
# Crontab command: Not recommended
# Supporting file: 
# Additional notes: Remember to set the custom variables for your environment
##############################################################################
# Declare variables
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/slpmod.log"
S1=$(cat /etc/slp.conf | grep -w useScopes | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')

# Show the current scopes
echo "The current scope(s) is: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

if [ -z "$1" ]; then
  echo "WARNING"
  echo "--------------------------------------------------------"
  echo "The new scope name was not provided on the command line."
  echo "Use the following command line format:"
  echo -e "./slpmod.sh <SCOPE_NAME>"
  echo "========================================================"
  exit
else
  # Add new scope
  sed -i "s/net.slp.useScopes = $S1/net.slp.useScopes = $S1,$1/" /etc/slp.conf
  # Restart affected daemons
  /usr/sbin/rcslpd restart
  # /usr/sbin/ndsd restart
fi

# Show the new scopes
echo "The new scopes are: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

#Finished
exit 1

