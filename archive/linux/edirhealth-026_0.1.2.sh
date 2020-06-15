#!/bin/bash - 
#===============================================================================
#
#          FILE: edirhealth.sh
# 
#         USAGE: ./edirhealth.sh 
# 
#   DESCRIPTION: Script to check nds health on the local server.
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
#         NOTES: Can be run daily as a cron job, or manually
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Wed Oct 02 2013 13:04
#  LAST UPDATED: Mon Jul 20 2015 13:35
#      REVISION: 2
#     SCRIPT ID: 026
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.2
sid=026                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/edirhealth.log'               # logging (if required)
DS=$(date +%a)                              # Abreviated day of week
DF=$(date +%A)                              # Full day of week
ndsbin=/opt/novell/eDirectory/bin           # Path to nds binaries
ndsconf=/etc/opt/novell/eDirectory/conf/nds.conf  # Path to nds configuration files
fn=$HOST$DF                                 # Name for eDirectory health report
adm=admin.rnd                               # Administrator's account name

# Create folder to store report
if [ -d /backup/$HOST/health ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$HOST/health
fi

# Run ndscheck
$ndsbin/ndscheck -a $adm -F /backup/$host/health/$fn -W -q --config-file $ndsconf

# E-mail the results
if [ -n "$email" ]; then
  mail -s "eDirectory Health Check for $host" $email < /backup/$host/health/$fn
fi

# Finished
exit 1

