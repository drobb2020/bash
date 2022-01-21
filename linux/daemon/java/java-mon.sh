#!/bin/bash - 
#===============================================================================
#
#          FILE: java-mon.sh
# 
#         USAGE: ./java-mon.sh 
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
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Feb 10 2016 11:12
#  LAST UPDATED: Thu Apr 28 2016 13:19
#      REVISION: 0.1.6
#     SCRIPT ID: ---
# SSC UNIQUE ID: --
#===============================================================================
ts=$(date +"%b %d %T")                          # general date/time stamp
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
log='/var/log/java-mon.log'                     # logging (if required)
email=root                                      # who to send email to (comma separated list)

function initlog() { 
  if [ -e "$log" ]; then
    echo -e "Log file exits, continuing." > /dev/null
  else
    touch "$log"
    echo -e "Logging started at ${ts}";
    echo -e "All actions are being performed by the user: ${user}";
    echo -e "" >> "$log"
  fi
}

function logit() { 
  echo -e "$ts" "$host" "$@" >> "$log"
}

initlog

# Run top and grab information about the Java process only!
jp=$(/bin/pidof java)
cpu=$(/usr/bin/top -b -n 1 -p "$jp" | sed -n '8p' | awk '{print $9}')

# Is java running above 50% - send an email
if [ "$cpu" -ge 50 ]; then
  echo -e "The java daemon (novell-tomcat6) is using $cpu%. This means that iManager is using more CPU than expected. At 100% novell-tomcat6 will be restarted to resolve the issue. Please check the server now to see if there is anything that can be done to resolve the issue." | mail -s "Java CPU utilization is high on $host" "$email"
fi

# Is java running above 100% - restart novell-tomcat6
if [ "$cpu" -ge 100 ]; then
  logit "Java CPU utilization is running at $cpu%"
  logit "This could cause issues with other processes."
  logit "Take a gstack of java before restarting."
  /bin/date > /root/java_gstack_"$host"_"$(date +'%Y%m%d')".txt
  
  for i in 1 2 3 4 5
  do
    echo "gstack #$i";
    /usr/bin/gstack "$jp";
    echo "" >> /root/java_gstack_"$host"_"$(date +'%Y%m%d')".txt
    sleep 5
  done

  logit "Five gstacks of java have been taken 5 seconds apart."
  logit "A restart of novell-tomcat6 will now take place."
  /etc/init.d/novell-tomcat6 restart
  sleep 25
  /etc/init.d/novell-tomcat6 status
  tcReturnCode=$?
  if [ $tcReturnCode = 0 ]; then
    logit "The restart of novell-tomcat6 was successful."
  else
    echo -e "The java daemon (novell-tomcat6) was using $cpu%, and a script was executed to restart the daemon. However novell-tomcat6 did not respond that it was running in a timely manner. Please check $host to see if manual intervention is required." | mail -s "novell-tomcat6 restart failure on $host" $email
  logit "The restart of novell-tomcat6 failed, an email has been sent to $email."
  fi
else
  logit "Java CPU utilization at this time is $cpu%."
  logit "---------------------------------------------------"
fi

exit 0
