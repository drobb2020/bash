#!/bin/bash - 
#===============================================================================
#
#          FILE: core-config.sh
# 
#         USAGE: ./core-config.sh 
# 
#   DESCRIPTION: Script to configure an OES server to write application cores to 
#                a specific location and with a particular file name
#
#                Copyright (c) 2021, David Robb
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
#       CREATED: Fri Dec 11 2015 10:30
#  LAST UPDATED: Thu Feb 12 2021 14:41
#       VERSION: 0.2.2
#     SCRIPT ID: 070
# SSC SCRIPT ID: 00
#===============================================================================
coredir='/var/core'                    # default location for application cores
#===============================================================================
# Create /var/core to store application core files
echo "Creating /var/core directory for application core files"
install -m 1777 -d $coredir
echo ""

# configure a custom core_pattern - becomes active on the system right away

echo "/var/core/core.%e.%h.%t" > /proc/sys/kernel/core_pattern
echo 1 > /proc/sys/kernel/core_uses_pid

# Configure the two core settings to be persistent across reboots
echo "Configuring /etc/sysctl.d/50-coredump.conf for custom core naming pattern"
if grep -qi 'application core' /etc/sysctl.d/50-coredump.conf 2>/dev/null; then
  echo -e "50-coredump.conf file already configured"
else
  echo -e "# Application core custom configuration settings" >> /etc/sysctl.d/50-coredump.conf
fi

if grep -q core_pattern /etc/sysctl.d/50-coredump.conf; then
  echo -e "Desired core_pattern already set in 50-coredump.conf"
else
  echo -e "kernel.core_pattern = /var/core/core.%e.%h.%t" >> /etc/sysctl.d/50-coredump.conf
fi

if grep -q core_uses_pid /etc/sysctl.d/50-coredump.conf; then
  echo -e "core_uses_pid already set in 50-coredump.conf"
else
  echo -e "kernel.core_uses_pid = 1" >> /etc/sysctl.d/50-coredump.conf
fi
echo ""

# Check the prlimit for ndsd
echo "Checking to ensure the prlimit for a ndsd core is set to unlimited"
/usr/bin/prlimit -p 1287 | grep 'RESOURCE\|CORE'

# Create a daily crontab task to run core-checker
echo "Creating crontab entry to run script every 8 hours"
if crontab -l | grep -q core; then
  echo -e "root's crontab is configured to run the core-checker script."
else
  crontab -l > cccron
  echo "0 */8 * * * /root/bin/core-checker.sh" >> cccron
  crontab cccron
  rm cccron
fi

# Finished
exit 0
