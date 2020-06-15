#!/bin/bash - 
#===============================================================================
#
#          FILE: 11minmode.sh
# 
#         USAGE: ./11minmode.sh 
# 
#   DESCRIPTION: check if 11 minute mode is enabled
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
#       CREATED: Tue Aug 08 2017 09:00
#   LAST UDATED: Sun Mar 18 2018 12:20
#       VERSION: 0.1.2
#     SCRIPT ID: 083
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.2                                    # version number of the script
sid=083                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=                                           # email sender
email=                                           # email recipient(s)
log='/var/log/11minmode.log'                     # log name and location (if required)
#===============================================================================

# Is 11 minute mode enabled?
adjtimex --print | awk '/status/ {
    if ( and($2, 64) == 0 ) {
        print "11 minute mode is enabled"
    } else {
        print "11 minute mode is disabled"
    }
}'

# Finished
exit 1

