#!/bin/bash - 
#===============================================================================
#
#          FILE: zmdreset.sh
# 
#         USAGE: ./zmdreset.sh 
# 
#   DESCRIPTION: Reset the zmd registration so the server can be reregistered with NCC or a SMT server
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
#       CREATED: Fri Jun 10 2011 14:00
#  LAST UPDATED: Sun Jun 19 2016 12:08
#      REVISION: 4
#     SCRIPT ID: 021
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.5
sid=021                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/zmdreset.log'                     # logging (if required)

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

