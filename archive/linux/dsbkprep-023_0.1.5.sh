#!/bin/bash - 
#===============================================================================
#
#          FILE: dsbkprep.sh
# 
#         USAGE: ./dsbkprep.sh 
# 
#   DESCRIPTION: Configure roll forward logs for use with dsbk backups and restores
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
#       CREATED: Mon Sep 16 2013 09:00
#   LAST UDATED: Tue Mar 13 2018 09:49
#       VERSION: 0.1.5
#     SCRIPT ID: 023
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.5                                    # version number of the script
sid=023                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=dsbk-setup                                 # email sender
email=root                                       # email recipient(s)
log='/var/log/dsbkprep.log'                      # log name and location (if required)
ndsbin=/var/opt/novell/eDirectoroy/bin           # path to nds binaries
#===============================================================================

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
  $ndsbin/dsbk setconfig -L -r /var/rfl
  sleep 30
fi

# Finished

