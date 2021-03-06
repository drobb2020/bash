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
#       CREATED: Tue Dec 08 2015 12:29
#   LAST UDATED: Thu Mar 01 2018 14:18
#       VERSION: 0.1.9
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.9                                    # version number of the script
sid=000                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=core-checker                               # email sender
email=root                                       # email recipient(s)
log='/var/log/core-checker.log'                  # log name and location (if required)
coredir='/var/core'                              # default location for application cores
dumpdir='/var/crash'                             # default location for kernel core dumps
mailc="/root/.mailcount"                         # file to restrict mail being sent more than once
maila="/root/cores.txt"				                   # details about the cores
cronfreq=8				                      	       # how often (once every X hours) to run the core-checker script
#===============================================================================

function initlog() { 
if [ -e "$log" ]; then
  echo "Log file exists" > /dev/null
else
  touch "$log"
  echo "========[ core-checker log ]========" > ${log}
  echo "Logging started at ${ts}" >> ${log}
  echo "All actions are being performed by the user ${user}" >> ${log}
  echo " " >> ${log}
fi
}

function logit() { 
  echo -e $ts $host: $* | tee -a ${log} >> ${maila}
}

initlog

# check for the existence of the mailcounter file
if [ -e /root/.mailcount ]; then
  echo "mailcounter exists" > /dev/null
else
  touch /root/.mailcount
  echo "mailed=0" > $mailc
fi

# Create an empty cores.txt
rm -f /root/cores.txt
touch /root/cores.txt

# Do we have a core?
core=$(ls $coredir | grep core)
ccount=$(ls $coredir | wc -l)

if [ -n "$core" ]; then
	if [ $ccount = 1]; then
    logit "The server has generated application core."
  else
	  logit "The server has generated multiple applications cores."
	fi
fi

# How many cores do we have?
if [ -n "$core" ]; then
  logit "The server has generated $ccount core(s)"
  logit "The following core(s) exist under /var/core:"
  clist=/tmp/clist.tmp.$$
  ls $coredir >> $clist
  cat $clist | tee -a $log >> $maila
fi

if [ -n "$core" ]; then
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
    cpath=$(/usr/bin/which "$cproc")
    logit "==[ core details ]==============================="
    logit "The core happened in: $cproc"
    logit "The core occurred at: $rtime"
    logit "The process ID (pid) is: $cpid"
    logit "The path to the process binary is: $cpath"
  done
else
  logit "There are no application cores present."
fi

function mail_body() { 
echo -e "An application core has been generated on $host. Please review /var/log/core-checker.log for the name(s) and details of the core(s). Login to the server and ensure that affected process has recovered on its own, otherwise the daemon(s) will need to be restarted (stop and then start).\nTo prepare the core(s) please follow the general steps listed in TID #7004526 (copy attached). The tasks to complete are:\n\n1. Contact the Micro Focus Dedicated Support Engineer and let him know a core(s) has occurred. Please provide details about what was happening on the server at the time of the core. Give the DSE time to open a new Service Request. He will provide you with a SR number when it is done.\n\n2. Use the chkbin utility provided with supportutils to check the health of the application(s) that cored. You can use the linux command \"which (process name)\" to find the path to the binary, the chkbin command would then be \"chkbin /path/to/process\".\n\n3. Use the already installed novell-getcore to package the core and system information into a single tarball. The syntax for novell-getcore is: \"novell-getcore -b /var/core/(core name) (/path/to/process)\". The packaged core will be written to the current working directory.\n\n4. Run supportconfig on the server using the following syntax: \"supportconfig -r srnum\" (substitute srmun with the 12 digit number provided by the DSE). This will generate the supportconfig in the usual place and the filename will include the SR number provided by the DSE.\n\n5. Copy both the supportconfig and core off the server. If the size of the two files is under 50 MB you can email the files to the DSE; if over 50 MB you will need to upload the files to \"ftp.novell.com/incoming\". Please make sure each file contains the SR number provided by the DSE. The SR number should be appended to the beginning of the file name and not replace the entire file name. Please provide the DSE with the names of the two files if uploaded via FTP.\n\nOnce the core has been processed please run the script core-cleanup.sh to remove the core."
}

. /root/.mailcount

if [ $mailed = 0 ]; then
  if [ -n "$core" -a "$email" ]; then
    mail_body | mail -s "An application core has occurred on $host" -a /root/7004526.pdf -a /root/cores.txt -r $mfrom $email
    echo "mailed=1" > $mailc
  else
    logit "The core-checker script will run again in $cronfreq hours."
  fi
else
  logit "A mail message about the current application core has been sent, not resending."
fi

# clean up temp files
if [ -n "$core" ]; then
  rm -f $clist
fi

