#!/bin/bash - 
#===============================================================================
#
#          FILE: core-checker.sh
# 
#         USAGE: ./core-checker.sh 
# 
#   DESCRIPTION: Script to check for the existence of core files and alert the 
#                appropriate administrator
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
#       CREATED: Tue Dec 08 2015 12:29
#  LAST UPDATED: Thu Feb 12 2021 15:32
#       VERSION: 0.1.10
#     SCRIPT ID: 068
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")          # general date|time stamp
host=$(hostname)                # hostname of the local server
user=$(whoami)                  # who is running the script
mfrom=core-checker              # email sender
email=root                      # email recipient(s)
log='/var/log/core-checker.log' # log name and location (if required)
coredir='/var/core'             # default location for application cores
mailc="/root/.mailcount"        # restrict mail being sent more than once
cronfreq=8                      # how often core-checker is run
#===============================================================================

# Initialize logging
function initlog() { 
if [ -e "($log)" ]; then
  echo "Log file exists" > /dev/null
else
  touch "($log)"
  echo "======= [ core-checker log ]=======" > "(${log})"
  echo "Logging started at ${ts}" >> ${log}
  echo "All actions are being performed by the user ${user}" >> "(${log})"
  echo " " >> "(${log})"
fi
}

function logit() { 
  echo -e "$ts" "$host": "$@" | tee -a ${log}
}

initlog

# check for the existence of the mailcounter file
if [ -e /root/.mailcount ]; then
  echo "mailcounter exists" > /dev/null
else
  touch /root/.mailcount
  echo "mailed=0" > $mailc
fi

# Delete any old cores.txt file and create an empty one
rm -f /root/cores.txt
touch /root/cores.txt

# Check for the existence of core?
newcore=$(/usr/bin/ls $coredir | grep core)
if [ -n "$newcore" ]; then
  logit "---------------------------------"
  logit "New core(s) were generated today."
  logit "================================="
fi

# How many cores do we have?
if [ -n "$newcore" ]; then
  ccount=$(/usr/bin/ls $coredir | wc -l)
  logit "The server has generated $ccount core(s)"
  logit "The following core(s) exist under /var/core:"
  clist=/tmp/clist.tmp.$$
  ls $coredir >> $clist
  # cat $clist | tee -a $log
fi

if [ -n "$newcore" ]; then
  list=$(cat /tmp/clist.tmp.$$)
  for c in $list
  do
    # Get the Unix time string from the core
    utime=$(echo "$c" | cut -f4 -d ".")
    # Convert the Unix time string to something humans can read
    rtime=$(/bin/date -d@"$utime")
    # Give us the name of the process that generated the core
    cproc=$(echo "$c" | cut -f2 -d ".")
    # Give us the pid of the process that generated the core
    cpid=$(echo "$c" | cut -f5 -d ".")
    # find the path to the cproc in question
    cpath=$(/usr/bin/which "$cproc")
    logit "== [ core details ]==============================="
    logit "The core happened in: $cproc"
    logit "The core occurred at: $rtime"
    logit "The process ID (pid) is: $cpid"
    logit "The path to the process binary is: $cpath"
  done
else
  logit "The server is healthy and there are no new cores."
fi

function mail_body1() { 
echo -e "A new core has been generated on $host. Please review /var/log/core-checker.log for the name(s) and details of the core(s). Login to the server and ensure that affected process has recovered on its own, otherwise the daemon(s) will need to be restarted (stop and then start).\nTo prepare the core(s) please follow the general steps listed in TID #7004526 (copy attached). The tasks to complete are:\n\n1. Contact the Micro Focus Dedicated Support Engineer and let him know a core(s) has occurred. Please provide details about what was happening on the server at the time of the core. Give the DSE time to open a new Service Request. He will provide you with a SR number when it is done.\n\n2. Use the chkbin utility provided with supportutils to check the health of the application(s) that cored. You can use the linux command \"which (process name)\" to find the path to the binary, the chkbin command would then be \"chkbin /path/to/process\".\n\n3. Use the already installed novell-getcore to package the core and system information into a single tarball. The syntax for novell-getcore is: \"novell-getcore -b /var/core/(core name) (/path/to/process)\". The packaged core will be written to the current working directory.\n\n4. Run supportconfig on the server using the following syntax: \"supportconfig -r srnum\" (substitute srnum with the 12 digit number provided by the DSE). This will generate the supportconfig in the usual place and the filename will include the SR number provided by the DSE.\n\n5. Copy both the supportconfig and core off the server. If the size of the two files is under 50 MB you can email the files to the DSE; if over 50 MB you will need to upload the files to \"ftp.novell.com/incoming\". Please make sure each file contains the SR number provided by the DSE. The SR number should be appended to the beginning of the file name and not replace the entire file name. Please provide the DSE with the names of the two files if uploaded via FTP.\n\nOnce the core has been processed please run the script core-cleanup.sh to remove the core."
}

. /root/.mailcount

if [ "$mailed" = 0 ]; then
  if [ -n "$newcore" ] && [ -a "$email" ]; then
    mail_body1 | mail -s "An application core has occurred on $host" -a /root/7004526.pdf -a /root/cores.txt -r "$mfrom" "$email"
    echo "mailed=1" > "$mailc"
  else
    logit "Will check again in $cronfreq hours to see if a new application core has occurred."
    logit "---------------------------------------------------------------------------"
  fi
else
  logit "A mail message about the current core has already been sent, not resending."
  logit "---------------------------------------------------------------------------"
fi

# clean up temp files
if [ -n "$newcore" ]; then
  rm -f $clist
fi
