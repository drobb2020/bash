#!/bin/bash - 
#===============================================================================
#
#          FILE: edirhealth.sh
# 
#         USAGE: ./edirhealth.sh 
# 
#   DESCRIPTION: Script to check nds health on the local server.
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
#         NOTES: Can be run daily as a cron job, or manually
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Wed Oct 02 2013 13:04
#  LAST UPDATED: Sun Jun 19 2016 13:00
#      REVISION: 2
#     SCRIPT ID: ---
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.3
sid=026                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/edirhealth.log'                   # logging (if required)
ndsbin=/opt/novell/eDirectory/bin               # Path to nds binaries
ndsconf=/etc/opt/novell/eDirectory/conf/nds.conf  # Path to nds configuration files
fn=$host$df                                     # Name for eDirectory health report
adm=admin.rnd                                   # Administrator's account name

# Create folder to store report
if [ -d /backup/$host/health ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$host/health
fi

# Run ndscheck
$ndsbin/ndscheck -a $adm -F /backup/$host/health/$fn -W -q --config-file $ndsconf

# E-mail the results
if [ -n "$email" ]; then
  mail -s "eDirectory Health Check for $host" $email < /backup/$host/health/$fn
fi

# Finished
exit 1

