#!/bin/bash - 
#===============================================================================
#
#          FILE: java_mon.sh
# 
#         USAGE: ./java_mon.sh 
# 
#   DESCRIPTION: Check if java (tomcat) is using more than 100% CPU and 
#                restart novell-tomcat6 if it is
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
#       OPTIONS: 30 * * * * /root/bin/java_mon.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Wed Feb 10 2016 11:12
#  LAST UPDATED: Wed Feb 10 2016 12:21
#      REVISION: 1
#     SCRIPT ID: ---
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.1                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
log='/var/log/java_mon.log'                     # logging (if required)
email=calvin.hamilton@rcmp-grc.gc.ca,david.robb@rcmp-grc.gc.ca,chandler.pigeon@rcmp-grc.gc.ca      # who to send email to (comma separated list)

function initlog() { 
  if [ -e $log ]; then
    echo -e "Log file exits, continuing." > /dev/null
  else
    touch /var/log/java_mon.log
    echo -e "Logging started at ${ts}" > ${log}
    echo -e "All actions are being performed by the user: ${user}" >> ${log}
    echo -e "" >> ${log}
  fi
}

function logit() { 
  echo -e $ts $host $* >> ${log}
}

initlog

# Run top and grab information about the Java process only!
jp=$(/bin/pidof java)
cpu=$(/usr/bin/top -b -n 1 -p $jp | sed -n '8p' | awk '{print $9}')

# Is java running above 100%
if [ ${cpu} -ge 100 ]; then
  logit "Java CPU utilization is running at $cpu%"
  logit "This could cause issues with other processes."
  echo -e "The Java daemon (novell-tomcat6) is using $cpu%. This means that iManager is using more CPU than expecte. Please log onto $host and restart novell-tomcat6" | mail -s "High Java CPU utilization on $host" $email
  logit "email sent to $email."
else
  logit "Java CPU utilization at this time is $cpu%."
  logit "---------------------------------------------------"
fi

exit 1

