#!/bin/bash - 
#===============================================================================
#
#          FILE: core-config.sh
# 
#         USAGE: ./core-config.sh 
# 
#   DESCRIPTION: Script to configure an OES server to write application cores to 
#                a specifc location and with a particular file name
#
#                Copyright (C) 2015  David Robb
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
#          BUGS: Report bugs to David Robb, drobb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Dec 11 10:30:00 2015 
#  LAST UPDATED: Wed Dec 30 08:38:24 2015 
#      REVISION: 1
#     SCRIPT ID: ---
# SSC UNIQUE ID: ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
version=0.1.1                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # user checking routine
email=root                                      # default email value
log='/var/log/core-config.log'                  # logging (if required)
coredir='/var/core'                             # default location for application cores
kdumpdir='/var/crash'                           # default location for kernel core dumps

# Create /var/core to store application core files
install -m 1777 -d /var/core

# configure a custom core_pattern - becomes active on the system right away
echo "/var/core/core.%e.%h.%t" > /proc/sys/kernel/core_pattern
echo "1" > /proc/sys/kernel/core_uses_pid

# Configure the two settings to be persistent across reboots
echo -e "# Application core configuration settings" >> /etc/sysctl.conf
echo -e "core_pattern = /var/core/core.%e.%h.%t" >> /etc/sysctl.conf
echo -e "core_uses_pid = 1" >> /etc/sysctl.conf

# Report which OES applications have ulimit -c unlimited already set
echo -e "The following OES services are currently enable to capture a core dump automatically"
/bin/grep -n 'ulimit -c' /etc/init.d/namcd /etc/init.d/ndsd /etc/init.d/novell-cifs /etc/init.d/novell-dfs /etc/init.d/novell-gmetad /etc/init.d/novell-gmond /etc/init.d/novell-httpstkd /etc/init.d/novell-nss /etc/init.d/novell-smdrd /etc/init.d/novell-tomcat6 /etc/init.d/novell-xregd /etc/init.d/novfsd

exit

