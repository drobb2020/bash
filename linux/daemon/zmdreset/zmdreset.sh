#!/bin/bash - 
#===============================================================================
#
#          FILE: zmdreset.sh
# 
#         USAGE: ./zmdreset.sh 
# 
#   DESCRIPTION: Reset the zmd registration so the server can be reregistered
#                with NCC or a SMT server
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
#       CREATED: Fri Jun 10 2011 14:00
#   LAST UDATED: Tue Mar 13 2018 08:24
#       VERSION: 0.1.6
#     SCRIPT ID: 021
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.6                                    # version number of the script
sid=021                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=zmd-modification                           # email sender
email=root                                       # email recipient(s)
log='/var/log/zmdreset.log'                      # log name and location (if required)
#===============================================================================

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

# Finished
exit 1

