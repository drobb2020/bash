#!/bin/bash - 
#===============================================================================
#
#          FILE: adjNcpThreads.sh
# 
#         USAGE: ./adjNcpThreads.sh 
# 
#   DESCRIPTION: Script to adjust NCP threads on OES
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
#       CREATED: Thu Mar 19 2015 09:39
#  LAST UPDATED: Thu Mar 15 2018 07:48
#       VERSION: 0.1.4
#     SCRIPT ID: 040
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script
log='/var/log/adjNcpThreads.log'                 # log name and location (if required)
DIALOG=${DIALOG=dialog}                          # If you want the script to run in an 
                                                 # x windows (such as xming) change
																								 # dialog to xdialog.
#===============================================================================

# Check to see if user is root
if [ "$user" != "root" ]; then
  echo "You must be root to run this script, but you are: $user."
  echo "The script will now exit. Please sudo to root and try again."
  exit 1
fi

# Lets log everything we do
function initlog() { 
  if [ -e "$log" ]; then
    echo "log file exists" > /dev/null
  else
    touch "$log"
    echo "Logging started at ${ts}" > "$log"
    echo "All actions are being performed by the user: ${user}" >> "$log"
    echo " " >> "$log"
  fi
}

# Date and timestamp each entry
function logit() { 
  echo -e "$ts" "$host" "$@" >> "$log"
}

# Initialize the log
initlog

# Log header
logit "SSC/RCMP OES11 SP2 post configuration NCP thread adjustment"
logit "==========================================================="
logit " "

# Current NCP Thread Settings
logit "-------------------------------------"
logit "Current Novell Core Protocol Settings"
logit "-------------------------------------"
/sbin/ncpcon threads >> "$log"
clear

# NCP Configuration Changes
logit "-------------------------------------"
logit "Novell Core Protocol Settings Change"
logit "-------------------------------------"
# No error checking required on these settings.
/sbin/ncpcon set CONCURRENT_ASYNC_REQUESTS=128
/sbin/ncpcon set ADDITIONAL_SSG_THREADS=75
echo "NCP server settings have been modified"
logit "The following NCP settings were made:\n\t\t\t\tCONCURRENT_ASYNC_REQUESTS set to 128.\n\t\t\t\tADDITIONAL_SSG_THREAD set to 75"
clear

# Post NCP Thread Settings
logit "------------------------------------"
logit "Post Novell Core Protocol Settings"
logit "------------------------------------"
/sbin/ncpcon threads >> "$log"
clear

# Finished
exit 0
