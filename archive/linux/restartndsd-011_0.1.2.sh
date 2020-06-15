#!/bin/bash - 
#===============================================================================
#
#          FILE: restartndsd.sh
# 
#         USAGE: ./restartndsd.sh 
# 
#   DESCRIPTION: SSC Restart script for ndsd daemon
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
#       OPTIONS: Remember to stagger the restart time on servers within the same replica ring
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Wed Jul 23 2014 07:36
#  LAST UPDATED: Mon Jul 20 2015 08:48
#      REVISION: 2
#     SCRIPT ID: 011
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.2
sid=011                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/restartndsd.log'              # logging (if required)

function initlog() { 
  if [ -e ${log} ]; then
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
logit "SSC ndsd restart script"
logit "=============================="
logit "------------------------------"
logit "NDSD monthly restart"
logit "------------------------------"

# Check current status of daemon
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode=$?
if [ $ndsdReturnCode = 0 ]
    then
        logit "Restart of ndsd issued by cron job on $host."
        /etc/init.d/ndsd restart | tee -a $log
	logit "Restart command issued."
fi

# Check new status of daemon (lets hope it's running)
/usr/sbin/rcndsd status &>/dev/null
ndsdReturnCode2=$?
if [ $ndsdReturnCode2 = 0 ]
    then
        logit "ndsd daemon successfully restarted."
	if [ -n $email ]
	    then
		echo -e "The ndsd daemon has successfully restarted on $host as per the monthly cron schedule. Please review the $log for any additional details." | mail -s "ndsd restarted on $host" $email
	fi
    else
        logit "For some reason the last restart of ndsd failed."
        logit "The daemon may be dead at this time."
        logit "Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors."
	if [ -n $email ] 
	    then
		echo -e "The scheduled restart of the ndsd daemon has failed and ndsd may not be running on $host. Please attempt a manual restart, and check the log (/var/opt/novell/eDirectory/log/ndsd.log) for errors." | mail -s "ATTENTION: ndsd restart on $host failed, please investigate!" $email
	fi
fi

logit "------------------------------"

exit 1

