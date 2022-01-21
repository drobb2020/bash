#!/bin/bash - 
#===============================================================================
#
#          FILE: set_attributes.sh
# 
#         USAGE: ./set_attributes.sh 
# 
#   DESCRIPTION: Set delete and rename inhibit on top level folders on an NSS #                volume
#
#                Copyright (c) 2021, David Robb
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
#                You should have received a copy of the GNU General Public #                License along with this program; if not, write to the Free #                Software Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Dec 15 2014 10:55
#  LAST UPDATED: Tue Feb 16 2021 17:10
#       VERSION: 0.1.8
#     SCRIPT ID: 042
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
log='/root/reports/nss/attributes.log'       # log name and location (if required)
nsssbin=/opt/novell/nss/sbin                     # path to NSS binaries
nssbase=/media/nss                               # path to NSS volumes
#===============================================================================
# Check to see if you are root
if [ "$user" != "root" ]; then
  echo ""
  echo "--[ Warning ]---------------------------"
  echo "You must be root to run this script."
  echo "The script will now exit. Please sudo to"
  echo "root, and run this script again."
  echo "========================================"
  exit 1
fi

# Create log directory
if [ -d ~/reports/nss ]; then
  echo "Reports folder exists, continuing ..." > /dev/null
else
  mkdir -p ~/reports/nss
fi

# Initialize logging
function initlog() { 
  if [ -e $log ]; then
    echo "log file exists" > /dev/null
  else
    echo "Logging started at ${ts}"; echo "All actions are being performed by the user: ${user}"; echo " " >> ${log}
  fi
}

function logit() { 
  echo "$ts" "$host" "$@" >> ${log}
}

initlog

# Get the NSS volume name from the user
echo "--[ NSS Volume Name ]----------------------------"
echo "Please provide the name of the NSS volume"
echo "(in uppercase) you would like to set the"
read -rp "attributes for: " vol
echo "-------------------------------------------------"
echo "The volume is: $vol"
echo "The full path is: $nssbase/$vol"

# Generate a list of the top level folders to work with
cd $nssbase/"$vol" || return
ls -d ./*/ > /tmp/dir_list.txt
DIRS=$(cat /tmp/dir_list.txt)
logit "The directories to be modified are: $DIRS"

# Exit for testing purposes
# exit 0

# Lets modify the attributes now
for d in $DIRS
  do
    $nsssbin/attrib ${nssbase}/"$vol"/"${d}" -s=di,ri | tee -a $log
  done

# Clean up temp file
rm -f /tmp/dir_list.txt

# Finished
exit 0
