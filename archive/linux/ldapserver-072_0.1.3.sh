#!/bin/bash - 
#===============================================================================
#
#          FILE: ldapserver.sh
# 
#         USAGE: ./ldapserver.sh 
# 
#   DESCRIPTION: Do an ldap querey to get the current list of OES servers that will need the local scripts updated by rsync.
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
#       CREATED: Tue Jun 24 2014 08:49
#  LAST UPDATED: Sun Jun 19 2016 15:08
#      REVISION: 2
#     SCRIPT ID: 072
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.3
sid=072                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/ldapserver.log'                   # logging (if required)
ndsbin=/opt/novell/eDirectory/bin               # path to nds utilities

function initlog() { 
   if [ -e ${log} ]
	then
		echo "log file exists" > /dev/null
	else
		touch ${log}
		echo "Logging started at ${ts}" > ${log}
		echo "All actions are being performed by the user: ${user}" >> ${log}
		echo " " >> ${log}
    fi
}

function logit() { 
	echo -e $ts $host: $* >> ${log}
}

initlog

# Get the current listing of servers
$ndsbin/ldapsearch -x -b "" -s sub "objectclass=uamPosixWorkstation" | grep cn=UNIX | cut -f 5 -d " " | cut -f 1 -d "," > /opt/scripts/os/servers.txt | tee -a $log

# Remove the source server from the list of servers
sed -i 's/acpic-s2860//g' /opt/scripts/os/servers.txt | tee -a $log
sed -i '/^\s*$/d' /opt/scripts/os/servers.txt | tee -a $log

# We will use the information gained from this script in an rsync script

# Finished
exit 1

