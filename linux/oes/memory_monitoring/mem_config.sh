#!/bin/bash - 
#===============================================================================
#
#          FILE: mem_config.sh
# 
#         USAGE: ./mem_config.sh 
#
#   DESCRIPTION: Modify default virtual memory configuration for OES2015 SP1
#
#                Copyright (c) 2017, David Robb
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
#       CREATED: Sat Jan 14 2017 09:17
#  LAST UPDATED: Sun Jan 15 2017 07:56
#       VERSION: 0.1.3
#     SCRIPT ID: 000
# SSC UNIQUE ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                          # general date|time stamp
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
log="/root/${host}_memory_config.log"           # logging (if required)
#===============================================================================
function initlog() { 
if [ -e "$log" ]; then
  echo "log file exists" > /dev/null
else
  touch "$log"
  echo "Logging started at ${ts}" > "$log"
  echo "All actions are being performed by the user: ${user}" >> "$log"
  echo " " >> "$log"
fi
}

function logit() { 
  echo -e "$ts" "$host": "$@" >> "$log"
}

initlog
# Turn off transparent_hugepage for the current session
logit "Turning off transparent hugepage for this session"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
# Turn transparent_hugepage off at boot
bm=$(grep transparent /boot/grub/menu.lst)
if [ -z "$bm" ]; then
	logit "Adding transparent_hugepage=never to grub boot menu so it is always disabled"
  awk '/splash/ {$0=$0" transparent_hugepage=never"} 1' /boot/grub/menu.lst > /tmp/menu.lst && mv /tmp/menu.lst /boot/grub/
else
  echo "Transparent_hugepage has already been added to the grub boot menu." | tee -a "$log"
fi

# Turn on zone_reclaim_mode for the current session
logit "Enabling zone reclaim mode for this session"
echo 1 > /proc/sys/vm/zone_reclaim_mode
# Enable zone_reclaim_mode
sc=$(grep "Virtual memory settings" /etc/sysctl.conf)
if [ -z "$sc" ]; then
	logit "Setting zone reclaim mode so it is persistent"
  echo -e "# Virtual memory settings" >> /etc/sysctl.conf
  echo -e "vm.zone_reclaim_mode = 1" >> /etc/sysctl.conf
else
  echo "Virtual memory settings have already been added to sysctl.conf" | tee -a "$log"
fi

# Check the current swappiness setting and adjust if necessary
swp=$(cat /proc/sys/vm/swappiness)
echo -e "The current swapiness setting is $swp" | tee -a "$log"
if [ "$swp" != 60 ]; then
	logit "Adjusting swappiness to 60%"
  sysctl -w vm.swappiness=60 | tee -a "$log"
  echo 60 > /proc/sys/vm/swappiness
  sw1=$(grep swappiness /etc/sysctl.conf)
  if [ -z "$sw1" ]; then
    echo -e "vm.swappiness = 60" >> /etc/sysctl.conf
  else
    echo "vm.swappiness already added to sysctl.conf" | tee -a "$log"
  fi
else
  if [ -z "$sw1" ]; then
    echo -e "vm.swappiness = 60" >> /etc/sysctl.conf
  else
    echo "vm.swappiness already added to sysctl.conf" | tee -a "$log"
  fi
fi

exit 0
