#!/bin/bash - 
#===============================================================================
#
#          FILE: cron-config.sh
# 
#         USAGE: ./cron-config.sh 
# 
#   DESCRIPTION: Set the shell and paths for crontab
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
#       CREATED: Fri Sep 01 2017 15:18
#   LAST UDATED: Thu Mar 01 2018 14:33
#       VERSION: 0.1.1
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.1                                    # version number of the script
sid=000                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=cron-config                                # email sender
email=root                                       # email recipient(s)
log='/var/log/cron-config.log'                   # log name and location (if required)
#===============================================================================

# Set the shell to bash
echo SHELL=/bin/sh >> ~/bin/tmp.cron

# Set the path to the current system environment
echo PATH=$PATH >> ~/bin/tmp.cron

# add a blank line into the file
echo >> ~/bin/tmp.cron

# Add the contents of the current user's crontab
crontab -l >> tmp.cron

# Clean tmp.cron of unneeded lines

# Import the new modified cron into crontab
crontab tmp.cron

exit 1

