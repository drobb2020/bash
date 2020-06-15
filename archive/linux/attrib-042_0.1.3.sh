#!/bin/bash - 
#===============================================================================
#
#          FILE: attrib.sh
# 
#         USAGE: ./attrib.sh 
# 
#   DESCRIPTION: Set delete and rename inhibit on top level folders on an NSS volume
#
#                Copyright (C) 2015  David Robb
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
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Mon Dec 15 2014 10:55
#  LAST UPDATED: Tue Jul 21 2015 12:21
#      REVISION: 3
#     SCRIPT ID: 042
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=042                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
ds=$(date +%a)                              # breviated day of the week, eg Mon
df=$(date +%A)                              # full day of the week, eg Monday
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/attrib.log'                   # logging (if required)
nsssbin=/opt/novell/nss/sbin                # Path to NSS binaries
nssbase=/media/nss                          # Path to NSS filesystems

function initlog() { 
  if [ -e $log ]; then
    echo "log file exists" > /dev/null
  else
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function logit() { 
  echo $ts $host $* >> ${log}
}

initlog

function helpme() { 
  echo "The correct command line syntax is ./attrib.sh VOL_NAME"
  echo "for example ./attrib.sh NCR_DATA1_PR"
  logit "Command execution failed"
  exit 1
}

# Generate a list of the top level folders to work with
ls -l $nssbase/$1 | grep "^d" | awk '{print $NF}' > /tmp/dir_list.txt
DIRS=$(cat /tmp/dir_list.txt)
logit "The directories to be modified are: $DIRS"

# Lets modify the attributes now
if [ $# -lt 1 ] ; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  for d in $DIRS
  do
    $nsssbin/attrib ${nssbase}/$1/${d} -s=di,ri | tee -a $log
  done
fi

# Separator for log
echo "--------------------------------------------------------------------------------" >> $log

# Clean up temp file
rm -f /tmp/dir_list.txt

exit 1 

