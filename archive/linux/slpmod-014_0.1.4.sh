#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmod.sh
# 
#         USAGE: ./slpmod.sh 
# 
#   DESCRIPTION: Modify the slp.conf file on a server to include a new scope name
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
#  REQUIREMENTS: ndsd must be restarted whenever slp is modified
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: Do not cron this job, should be run manually
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Mon Jan 07 2013 14:54
#  LAST UPDATED: Sun Jun 19 2016 11:46
#      REVISION: 3
#     SCRIPT ID: 014
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=014                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/slpmod.log'                       # logging (if required)
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
  # Restart affected daemons - eDirectory must be restarted after modifying slp
  /etc/init.d/slpd stop
  /etc/init.d/ndsd restart
	/etc/init.d/slpd start
fi

# Show the new scopes
echo "The new scopes are: $(/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//')"

#Finished
exit 1

