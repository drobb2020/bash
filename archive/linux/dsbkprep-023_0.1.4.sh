#!/bin/bash - 
#===============================================================================
#
#          FILE: dsbkprep.sh
# 
#         USAGE: ./dsbkprep.sh 
# 
#   DESCRIPTION: Configure roll forward logs for use with dsbk backups and restores
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
#       CREATED: Mon Sep 16 2013 09:00
#  LAST UPDATED: Sun Jun 19 2016 12:43
#      REVISION: 3
#     SCRIPT ID: 023
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=023                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/dsbkprep.log'                     # logging (if required)

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

