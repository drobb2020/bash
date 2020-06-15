#!/bin/bash - 
#===============================================================================
#
#          FILE: dsbkprep.sh
# 
#         USAGE: ./dsbkprep.sh 
# 
#   DESCRIPTION: Configure roll forward logs for use with dsbk backups and restores
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
#         NOTES: Do not cron this script, it is called from another script
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Mon Sep 16 2013 09:00
#  LAST UPDATED: Mon Jul 20 2015 12:16
#      REVISION: 3
#     SCRIPT ID: 023
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=023                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/dsbkprep.log'                 # logging (if required)

# Create dsbk.conf
if [ -f /etc/dsbk.conf ]; then
  echo "DSBK has been configured, continuing ..." >> /dev/null
else
  touch /tmp/dsbk.tmp
  echo "/tmp/dsbk.tmp" > /etc/dsbk.conf
fi

# Configure rfl for dsbk
if [ -d /var/rfl ]; then
  echo "RFL has been configured, continuing ..." >> /dev/null
else
  mkdir -p /var/rfl
  dsbk setconfig -L -r /var/rfl
  sleep 30
fi

exit 1

