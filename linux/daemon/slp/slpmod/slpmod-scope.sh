#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmod-scope.sh
# 
#         USAGE: ./slpmod-scope.sh 
# 
#   DESCRIPTION: Modify the slp.conf file on a server to include a new scope name
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
#  REQUIREMENTS: ndsd must be restarted whenever slp is modified
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Jan 07 2013 14:54
#  LAST UPDATED: Mon Mar 12 2018 12:19
#       VERSION: 0.1.5
#     SCRIPT ID: 014
# SSC SCRIPT ID: 00
#===============================================================================
S1=$(grep -w useScopes /etc/slp.conf | cut -f 2 -d "=" | sed -e 's/^[ \t]*//') # current scope name
#===============================================================================
# Show the current scopes
echo "The current scope(s) is: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

if [ -z "$1" ]; then
  echo "WARNING"
  echo "--------------------------------------------------------"
  echo "The new scope name was not provided on the command line."
  echo "Use the following command line format:"
  echo -e "./slpmod-scope.sh <SCOPE_NAME>"
  echo "========================================================"
  exit
else
  # Add new scope
  sed -i "s/net.slp.useScopes = $S1/net.slp.useScopes = $S1,$1/" /etc/slp.conf
  # Restart affected daemons - eDirectory must be restarted after modifying slp
	echo -e "The modification of slp.conf requires a restart of slpd and ndsd. Restarting now."
  /etc/init.d/slpd stop
  /etc/init.d/ndsd restart
	/etc/init.d/slpd start
	sleep 5
fi

# Show the new scopes
echo "The new scopes are: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

#Finished
exit 0
