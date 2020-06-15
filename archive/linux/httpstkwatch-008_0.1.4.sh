#!/bin/bash - 
#===============================================================================
#
#          FILE: httpstkwatch.sh
# 
#         USAGE: ./httpstkwatch.sh 
# 
#   DESCRIPTION: Script to monitor the httpstkd daemon and restart if necessary
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
#       OPTIONS: */5 * * * * root /root/bin/httpstkwatch.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Wed Dec 19 2012 08:47
#  LAST UPDATED: Sun Jun 19 2016 10:55
#      REVISION: 3
#     SCRIPT ID: 008
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4
sid=008                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/httpstkwatch.log'                 # logging (if required)

function initlog() { 
if [ -e ${log} ]; then
  echo "log file exists" > /dev/null
else
  touch $log
	echo "Logging started at ${ts}" > ${log}
	echo "All actions are being performed by the user: ${user}" >> ${log}
	echo " " >> ${log}
fi
}

function logit() { 
	echo $TS $HOST: $* >> ${log}
}

initlog

# Check the current status of novel-httpstkd
if [ -e /var/run/httpstkd.pid ]; then
  PIDD=$(cat /var/run/httpstkd.pid)
  PS=$(ps aux | grep httpstkd | grep -v grep | cut -f 7 -d " " | sed -n '1p')
  if [ $PIDD -eq $PS ]; then
    logit "novell-httpstkd appears to be running correctly"
	else
    logit "PID file exists but the daemon is dead"
    rm -f /var/run/httpstkd.pid
    kill -9 $PIDD
    /etc/init.d/novell-httpstkd restart
    logit "novell-httpstkd daemon has been restarted"
  fi
else
  logit "httpstkd.pid does not exist, daemon is stopped, going to do a restart."
  /etc/init.d/novell-httpstkd start
fi

exit 1

