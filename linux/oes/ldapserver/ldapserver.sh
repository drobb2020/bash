#!/bin/bash - 
#===============================================================================
#
#          FILE: ldapserver.sh
# 
#         USAGE: ./ldapserver.sh 
# 
#   DESCRIPTION: Do an ldap query to get the current list of OES servers 
#                that will need the local scripts updated by rsync
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
#       CREATED: Tue Jun 24 2014 08:49
#  LAST UPDATED: Thu Mar 15 2018 10:58
#       VERSION: 0.1.4
#     SCRIPT ID: 072
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                 # general date|time stamp
host=$(hostname)                       # hostname of the local server
user=$(whoami)                         # who is running the script
log='/var/log/ldapserver.log'          # log name and location (if required)
ndsbin='/opt/novell/eDirectory/bin'      # path to nds utilities
#===============================================================================

# Initialize logging
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

# Get the current listing of servers
$ndsbin/ldapsearch -x -b "" -s sub "objectclass=uamPosixWorkstation" | grep cn=UNIX | cut -f 5 -d " " | cut -f 1 -d "," > /opt/scripts/os/servers.txt

# Remove the source server from the list of servers
sed -i 's/acpic-s2860//g' /opt/scripts/os/servers.txt | tee -a $log
sed -i '/^\s*$/d' /opt/scripts/os/servers.txt | tee -a $log

# We will use the information gained from this script in an rsync script

# Finished
exit 0
