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
#       CREATED: Tue Jan 05 2016 11:38
#   LAST UDATED: Tue Mar 13 2018 11:21
#       VERSION: 0.1.3
#     SCRIPT ID: 064
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.3                                    # version number of the script
sid=064                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=ndsd-troubleshooting                       # email sender
email=root                                       # email recipient(s)
log='/root/'$host'_ndsd-collect.log'             # log name and location (if required)
#===============================================================================

# gstack of ndsd threads
get_gstack() { 
  ndsd_pid=$(/bin/ps -C ndsd | awk 'NR==2{print $1}')
  echo "==[ gstack collection ]=============================" >> $log
  /usr/bin/gstack $ndsd_pid >> $log
  echo "==[ end of gstack collection ]======================" >> $log
  echo "" >> $log
  echo "" >> $log
}

# ps output of ndsd
get_ps() { 
  echo "==[ ps collection ]=================================" >> $log
  /bin/ps -C ndsd -L -o pid,tid,nlwp,pcpu,pmem,vsz,stat >> $log
  echo "==[ end of ps collection ]==========================" >> $log
}

# force ndsd to generate a core 
force_gcore() { 
  ndsd_pid=$(/bin/ps -C ndsd | awk 'NR==2{print $1}')
  pushd .
  cd /root
  /usr/bin/gcore $ndsd_pid
  popd
}

# restart ndsd afterwards
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

