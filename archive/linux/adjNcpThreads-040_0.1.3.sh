#!/bin/bash - 
#===============================================================================
#
#          FILE: adjNcpThreads.sh
# 
#         USAGE: ./adjNcpThreads.sh 
# 
#   DESCRIPTION: Sript to adjust NCP threads
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
#       CREATED: Thu Mar 19 2015 09:39
#  LAST UPDATED: Sun Jun 19 2016 14:11
#      REVISION: 2
#     SCRIPT ID: 040
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.3
sid=040                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/adjNcpThreads.log'                # logging (if required)
DIALOG=${DIALOG=dialog}                     # If you want the script to run in an x windows (such as xming) change dialog to xdialog.

# Check to see if user is root
if [ $user != "root" ]; then
  echo "You must be root to run this script, but you are: $user."
  echo "The script will now exit. Please sudo to root and try again."
  exit 1
fi

# Lets log everything we do
function initlog() { 
  if [ -e $log ]; then
    echo "log file exists" > /dev/null
  else
    touch $log
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

# Date and timestamp each entry
function logit() { 
  echo -e $ts $host: $* >> ${log}
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
/sbin/ncpcon threads >> $log
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
/sbin/ncpcon threads >> $log
clear

# Finished
exit 1

