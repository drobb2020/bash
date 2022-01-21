#!/bin/bash - 
#===============================================================================
#
#          FILE: get_attributes.sh
# 
#         USAGE: ./get_attributes.sh 
# 
#   DESCRIPTION: Script to record the directories on an NSS volume that have 
#                rename and delete inhibit set
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
#                You should have received a copy of the GNU General Public #                License along with this program; if not, write to the 
#                Free Software Foundation, Inc., 
#                51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Feb 24 2015 09:35
#  LAST UPDATED: Tue Feb 16 2021 17:10
#       VERSION: 0.1.9
#     SCRIPT ID: 043
# SSC SCRIPT ID: 00
#===============================================================================
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
nsssbin=/opt/novell/nss/sbin                     # path to NSS binaries
nssbase=/media/nss                               # base path for NSS volumes
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

# Create reports directory
if [ -d ~/reports/nss ]; then
  echo "Reports folder exists, continuing ..." > /dev/null
else
  mkdir -p ~/reports/nss
fi

# Get the NSS volume name from the user
echo "--[ NSS Volume Name ]----------------------------"
echo "Please provide the name of the NSS volume"
echo "(in uppercase) you would like to extract"
read -rp "the attributes for: " vol
echo "-------------------------------------------------"
echo "The volume is: $vol"
echo "The full path is: $nssbase/$vol"

# Generate a list of the top level folders to work with
cd $nssbase/"$vol" || return
ls -d ./*/ > /tmp/dirs.txt
DIRS=$(cat /tmp/dirs.txt)

# Extract the file and folder attributes from the NSS DATA volume
for d in $DIRS
  do
    $nsssbin/attrib -rl $nssbase/"$vol"/"${d}" >> /root/reports/nss/"${host}"_attributes_"${vol}".log
  done

# Show the files and folders with read only attributes
grep -B 3 'Read Only\|Rename Inhibit\|Delete Inhibit' /root/reports/nss/"${host}"_attributes_"${vol}".log > /root/reports/nss/"${host}"_problem_files_"${vol}".txt

# Finished
exit 0
