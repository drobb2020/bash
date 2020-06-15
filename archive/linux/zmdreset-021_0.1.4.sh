#!/bin/bash - 
#===============================================================================
#
#          FILE: zmdreset.sh
# 
#         USAGE: ./zmdreset.sh 
# 
#   DESCRIPTION: Reset the zmd registration so the server can be reregistered with NCC
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
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Jun 10 2011 14:00
#  LAST UPDATED: Mon Jul 20 2015 11:50
#      REVISION: 4
#     SCRIPT ID: 021
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.4
sid=021                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/zmdreset.log'                 # logging (if required)

# Stop the Zenworks management daemon using
zmdstop () { 
/etc/init.d/novell-zmd stop 
}

# Remove the zmd cache using
rmcache () { 
rm -R /var/cache/zmd/* 
}

# Remove the zmd database using
rmdb () {
rm /var/lib/zmd/zmd.db 
}

# Remove the device ID using
rmdevid () {
rm /etc/zmd/deviceid 
}

# Remove the Zen secret using
rmsec () {
rm /etc/zmd/secret 
}

# Restart the Zenworks management daemon using 
zmdstrt () {
/etc/init.d/novell-zmd start 
}

# Delete the suseRegister cache file using
srcache () {
rm /var/cache/SuseRegister/lastzmdconfig.cache 
}

# Execute each function, ensuring each is complete before proceeding
zmdstop && rmcache && rmdb && rmdevid && rmsec && zmdstrt && srcache

exit 1

