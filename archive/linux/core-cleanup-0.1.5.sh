#! /bin/bash
#===============================================================================
#
#          FILE: core-cleaner.sh
# 
#         USAGE: ./core-cleaner.sh 
# 
#   DESCRIPTION: A script to cleanup old cores after the core has been processed.
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
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Dec 29 14:49 2015 
#  LAST UPDATED: Thu Apr 28 13:24 2016 
#      REVISION: 5
#     SCRIPT ID: ---
# SSC UNIQUE ID: ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
version=0.1.5                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # user checking routine
email=root                                      # default email value
log='/var/log/core-cleaner.log'                 # logging (if required)
coredir='/var/core'                             # default location for application cores
kdumpdir='/var/crash'                           # default location for kernel core dumps
mailc="/root/.mailcount"                        # file to restrict mail being sent more than once
maila="/root/cores.txt"                         # core details to email to admins

function core_cleaner { 
  rm -rv $coredir/*
  rm -rv $maila
  echo "mailed=0" > $mailc
  cat "mailcounter has been reset to: $mailc"
}

# Ask if all the cores in /var/core have been processed properly.
  echo "==[ Core(s) Processed? ]==============================="
  echo "Have all the core(s) on this server been process as per"
  echo "TID #7004526.pdf?"
  echo "The cores are:"
  ls $coredir
  echo "This script will clean up all associated files"
  echo "-------------------------------------------------------"
  echo " "
  read -r -p "All core(s) files have been processed (y/n)? " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    core_cleaner
  else
    echo "Please run the script again once you have processed the cores"
  fi

exit 1

