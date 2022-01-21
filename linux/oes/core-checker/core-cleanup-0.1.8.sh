#!/bin/bash - 
#===============================================================================
#
#          FILE: core-cleanup.sh
# 
#         USAGE: ./core-cleanup.sh 
# 
#   DESCRIPTION: script to cleanup old cores after processing
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
#       CREATED: Tue Dec 29 2015 14:49
#  LAST UPDATED: Thu Feb 12 2021 14:56
#       VERSION: 0.1.8
#     SCRIPT ID: 069
# SSC SCRIPT ID: 00
#===============================================================================
log='/var/log/core-cleanup.log'     # log name and location (if required)
coredir='/var/core'                 # default location for application cores
mailcnt="/root/.mailcount"          # file to restrict mail being sent more than once
maila1="/root/cores.txt"            # mail attachment 1 - core details
#===============================================================================
# What to cleanup after processing core files
function core_cleaner { 
  echo -e ">>> Removing core file(s)" | tee -a $log
  rm -rv "($coredir/*)" | tee -a $log
  echo -e ">>> Cleaning up cores.txt file" | tee -a $log
  rm -rv $maila1  | tee -a $log
	echo -e ">>> Resetting mail counter to 0" | tee -a $log
  echo "mailed=0" > $mailcnt
	echo "mailcounter has been reset to 0" | tee -a $log
	echo -e "Cleaning done, ready for the next core." | tee -a $log
  echo "-------------------------------------------------------"
}

# Ask if all the cores in /var/core have been processed properly.
  echo "==[ Core(s) Processed? ]==============================="
  echo "Have all the core(s) on this server been process as per"
  echo "TID #7004526.pdf?"
  echo "The cores are:"
  ls $coredir
  echo "This script will clean up all associated files"
  echo "-------------------------------------------------------"
  echo ""
  read -r -p "All core(s) files have been processed (y/n)? " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    core_cleaner
  else
    echo "Please run the script again once you have processed the cores"
  fi

exit 0
