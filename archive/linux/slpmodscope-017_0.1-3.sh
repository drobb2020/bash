#!/bin/bash
REL=0.1-3
SID=017
##############################################################################
#
#    slpmodscope.sh - A script to modify the slp.conf file on a server to
#                     include a new scope
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
# Last updated: 
# Crontab command: Not recommended
# Supporting file: 
# Additional notes: Remember to set the custom variables for your environment
##############################################################################
# Declare variables
RCF=/root/bin/rc-scope
S1=$(/usr/bin/slptool getproperty net.slp.useScopes | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')

if [ -e $RCF ]; then
  . $RCF
    if [ $RC = 1 ]; then
      echo "WARNING"
      echo "--------------------------------------------------------"
      echo "This script has already been run once." 
      echo "It is not recommended to run this script multiple times."
      echo "========================================================"
      exit 1
    fi
fi

# Show the current scopes
echo "The current scope(s) is: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

if [ -z "$1" ]; then
  echo "WARNING"
  echo "--------------------------------------------------------"
  echo "The new scope name was not provided on the command line."
  echo "Use the following command format:"
  echo -e "./slpmod.sh <SCOPE_NAME>"
  echo "========================================================"
  exit 1
else
  # Add new scope
  sed -i "s/net.slp.useScopes = $S1/net.slp.useScopes = $S1,$1/" /etc/slp.conf
  # Restart affected daemons
  /usr/sbin/rcslpd restart
  /usr/sbin/ndsd restart
fi

# Show the new scopes
echo "The new scopes are: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

# Set run count for this script
touch $RCF
echo "RC=1" >> $RCF

#Finished
exit 1

