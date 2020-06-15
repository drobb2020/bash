#!/bin/bash - 
#===============================================================================
#
#          FILE: ndsd-collect.sh
# 
#         USAGE: ./ndsd-collect.sh 
# 
#   DESCRIPTION: A script to collect a gstack, ps, and gcore of ndsd if ndsd
#                becomes unresponsive
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
#       CREATED: Tue Jan 05 2016 11:38
#  LAST UPDATED: Sun Jun 19 2016 13:15
#      REVISION: 1
#     SCRIPT ID: 064
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.2
sid=064                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/root/'${host}'_ndsd-collect.log'          # logging (if required)

get_gstack() { 
  ndsd_pid=$(/bin/ps -C ndsd | awk 'NR==2{print $1}')
  echo "==[ gstack collection ]=============================" >> $log
  /usr/bin/gstack $ndsd_pid >> $log
  echo "==[ end of gstack collection ]======================" >> $log
  echo "" >> $log
  echo "" >> $log
}

get_ps() { 
  echo "==[ ps collection ]=================================" >> $log
  /bin/ps -C ndsd -L -o pid,tid,nlwp,pcpu,pmem,vsz,stat >> $log
  echo "==[ end of ps collection ]==========================" >> $log
}

force_gcore() { 
  ndsd_pid=$(/bin/ps -C ndsd | awk 'NR==2{print $1}')
  pushd .
  cd /root
  /usr/bin/gcore $ndsd_pid
  popd
}

restart_ndsd() { 
  /etc/init.d/ndsd restart
  sleep 120
  /usr/sbin/rcndsd status &>/dev/null
  ndsdReturnCode=$?
  if [ $ndsdReturnCode = 1 ]; then
    echo "ndsd did not restart, please review the /var/opt/novell/eDirectory/log/ndsd.log for errors, and try again."
  else
    echo "ndsd was successfully restarted. Collect the log file and gcore in /root/ and send then to the DSE."
  fi
}

get_gstack && get_ps && force_gcore && restart_ndsd

exit 1

