#!/bin/bash - 
#===============================================================================
#
#          FILE: core-cleanup.sh
# 
#         USAGE: ./core-cleanup.sh 
# 
#   DESCRIPTION: Clean up application cores after they are processed.
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
#       CREATED: Tue Dec 29 2015 14:49
#   LAST UDATED: Thu Mar 01 2018 14:25
#       VERSION: 0.1.7
#     SCRIPT ID: 069
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.7                                    # version number of the script
sid=069                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=                                           # email sender
email=                                           # email recipient(s)
log='/var/log/core-cleanup.log'                  # log name and location (if required)
coredir='/var/core'                              # default location for application cores
kdumpdir='/var/crash'                            # default location for kernel core dumps
mailc="/root/.mailcount"                         # file to restrict mail being sent more than once
maila="/root/cores.txt"                          # core details to email to admins
#===============================================================================

function core_cleaner { 
  rm -rv $coredir/*
  rm -rv $maila
  echo "mailed=0" > $mailc
  cat "mailcounter has been reset to: $mailc"
}

# Ask if all the cores in /var/core have been processed properly.
  echo "==[ Application Core(s) Processed? ]==================="
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

