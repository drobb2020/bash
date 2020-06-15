#
#!/bin/bash - 
#===============================================================================
#
#          FILE: core-checker.sh
# 
#         USAGE: ./core-checker.sh 
# 
#   DESCRIPTION: Script to check for the existance of core files and alert the 
#                appropriate administrator
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
#          BUGS: Report bugs to David Robb, drobb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Dec 08 2015 12:29
#  LAST UPDATED: Wed Dec 30 11:49:42 2015 
#      REVISION: 4
#     SCRIPT ID: ---
# SSC UNIQUE ID: ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
version=0.1.4                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # user checking routine
email=root                                      # default email value
log='/var/log/core-checker.log'                 # logging (if required)
coredir='/var/core'                             # default location for application cores
kdumpdir='/var/crash'                           # default location for kernel core dumps
mailc="/root/.mailcount"                        # file to restrict mail being sent more than once

function initlog() { 
if [ -e "$log" ]; then
  echo "Log file exists" > /dev/null
else
  touch "$log"
  echo "======= [ core-checker log ]=======" > ${log}
  echo "Logging started at ${ts}" >> ${log}
  echo "All actions are being performed by the user ${user}" >> ${log}
  echo " " >> ${log}
fi
}

function logit() { 
  echo -e $ts $host: $* >> ${log}
}

initlog

# Do we have a core?
newcore=$(ls $coredir | grep core)
if [ -n "$newcore" ]; then
  logit "--------------------------------------------------"
  logit "New core(s) have been generated today."
fi

# How many cores do we have?
if [ -n "$newcore" ]; then
  ccount=$(ls $coredir | wc -l)
  logit "The server has generated $ccount core(s)"
  logit "The following core(s) exist under /var/core:"
  clist=/tmp/clist.tmp.$$
  ls $coredir >> $clist
  cat $clist | tee -a $log
fi

if [ -n "$newcore" ]; then
  list=$(cat /tmp/clist.tmp.$$)
  for c in $list
  do
    # Get the Unix time string from the core
    utime=$(echo $c | cut -f4 -d ".")
    # Convert the Unix time string to something humans can read
    rtime=$(/bin/date -d@$utime)
    # Give us the name of the process that generated the core
    cproc=$(echo $c | cut -f2 -d ".")
    # Give us the pid of the process that generated the core
    cpid=$(echo $c | cut -f5 -d ".")
    # Give us the full name of the core
    cname="$c"
    # find the path to the cproc in question
    cpath=$(which $cproc)
    logit "== [ core details ]==============================="
    logit "The core happened in: $cproc"
    logit "The core occurred at: $rtime"
    logit "The process ID (pid) is: $cpid"
    logit "The path to the process binary is: $cpath"
    logit "--------------------------------------------------"
  done
else
  logit "The server is healthy and there are no new cores."
fi

function mail_body() { 
echo -e "A new core has been generated on $host. Please review /var/log/core-checker.log for the name(s) and details of the core(s). Login to the server and ensure that affected processes have recovered on their own, otherwise the daemon(s) will need to be restarted (stop and then start).\nTo prepare the core(s) please follow the general steps listed in TID #7004526 (copy attached). The specific tasks to complete are:\n\n1. Contact the Micro Focus Dedicated Support Engineer and let him know a core(s) has occurred. Please provide details about what was happening on the server at the time of the core. Give the DSE time to open a new Service Request. He will provide you with a SR number when it is done.\n\n2. Use the chkbin utility provided with supportutils to check the health of the application(s) that cored. You can use the linux command \"which (process name)\" to find the path to the binary, the chkbin command would then be \"chkbin /path/to/process\".\n\n3. Use the already installed novell-getcore to package the core and system information into a single tarball. The syntax for novell-getcore is: \"novell-getcore -b /var/core/(core name) (/path/to/process)\". The packaged core will be written to the current working directory (cwd).\n\n4. Run supportconfig on the server using the following syntax: \"supportconfig -r srnum\" (substitute srmun with the 11 digit number provided by the DSE). This will generate the supportconfig in the usual place and the filename will include the SR number provided by the DSE.\n\n5. Copy both the supportconfig and core off the server. If the size of the two files is under 50MB you can email the files to the DSE; if over 50MB you will need to upload the files to \"ftp.novell.com/incoming\". Please make sure each file contains the SR number provided by the DSE. Please provide the DSE with the names of the two files if uploaded via FTP.\n\nOnce the core has been processed please run the script core-cleaner.sh to remove the raw core."
}
. $mailc
if [ $mailed = 0 ]; then
  if [ -n "$newcore" -a "$email" ]; then
    mail_body | mail -s "An application core has occurred on $host" -a /root/7004526.pdf $email
    touch $mailc
    echo "mailed=1" > $mailc
  else
    logit "Will check again in 24 hours to see if a new application core has occurred."
    logit "--------------------------------------------------------------------"
  fi
else
  logit "A mail message about the current core has already been sent, not resending."
  logit "--------------------------------------------------------------------"
fi

# clean up temp files
if [ -n "$newcore" ]; then
  rm -f $clist
fi

exit

