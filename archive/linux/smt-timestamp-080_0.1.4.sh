#!/bin/bash
#===============================================================================
#
#          FILE: smt-timestamp.sh
# 
#         USAGE: ./smt-timestamp.sh [testing|production]
# 
#   DESCRIPTION: Script to timestamp both testing and prodcution repositories
#
#                Copyright (C) 2016  David Robb
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENts: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: 
#  LAST UPDATED: Wed Nov 30 2016 07:18
#       VERSION: 4
#     SCRIPT ID: ---
# SSC UNIQUE ID: 00
#===============================================================================
version=0.1.4                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/smt/smt-timestamp.log'            # logging (if required)

function initlog() { 
    touch /var/log/smt/smt-timestamp.log
    echo -e "Logging started at ${ts}" > ${log}
    echo -e "All actions are being performed by the user: ${user}" >> ${log}
    echo =e "" >> ${log}
}

function logit() { 
  echo -e $ts $host $* >> ${log}
}

function helpme() { 
  echo ""
  echo ""
  echo "---------------------------------------------------------------------"
  echo "WARNING"
  echo "====================================================================="
  echo "You are missing a needed argument on the command line."
  echo "The expected syntax is: ./smt-timestamp.sh [testing | production]"
  echo "For example: ./smt-timestamp.sh production"
  echo "The script will now exit, please try again."
  echo "---------------------------------------------------------------------"
  echo ""
  echo ""
  exit 1
}

initlog

if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line."
  helpme
else
  # Get the repository names for all sle-11-x86_64 repositories
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-11
  echo "sle-11-x86_64 repository list has been generated"
  echo ""

  # Get the repository names for all sles-10-x86_64 repositories
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sle-11-x86_64 | grep -v sles-10-i586 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-10
  echo "sles-10-x86_64 repository list has been generated"
  echo ""

  # Get the repository names for all sles-10-i586 repositories
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sle-11-x86_64 | grep -v sles-10-x86_64 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-10_i586
  echo "sles-10-i586 repository list has been generated"
  echo ""

  echo "---------------------------------------------------------------------"
  echo "PROGRESS"
  echo "====================================================================="
  echo "The $1 repositories are being timestamped. All progress (success"
  echo "and errors) is being written to $log."
  echo "An error report (if any) will be generated once the script completes."
  echo "---------------------------------------------------------------------"
  echo ""
  
  # Now timestamp all patches so they can be installed
  list1=$(cat /root/bin/repo-names-11)
  for repo1 in $list1
    do 
      /usr/sbin/smt-staging createrepo $repo1 'sle-11-x86_64' --$1 >> ${log} 2>&1
    done
  list2=$(cat /root/bin/repo-names-10)
  for repo2 in $list2
    do
      /usr/sbin/smt-staging createrepo $repo2 'sles-10-x86_64' --$1 >> ${log} 2>&1
    done
  list3=$(cat /root/bin/repo-names-10_i586)
  for repo3 in $list3
    do
      /usr/sbin/smt-staging createrepo $repo3 'sles-10-i586' --$1 >> ${log} 2>&1
   done
fi

# Completion message
clear
err=$(cat /var/log/smt/smt-timestamp.log | grep -i 'checksum mismatch' | wc -l)
if [ ${err} -gt 0 ]; then
  echo ""
  echo "---------------------------------------------------------------------"
  echo "ERROR REPORT"
  echo "====================================================================="
  echo "The following repository(s) generated an error while being"
  echo "timestamped for $1."
  echo "Please correct these error(s) before timestamping for production"
        repo=$(cat /var/log/smt/smt-timestamp.log | grep -i 'checksum mismatch' | awk -F/ '{ print $8, $9}' | uniq | sort)
        errrpm=$(cat /var/log/smt/smt-timestamp.log | grep -i 'checksum mismatch' | awk -F/ '{ print $12}')
  echo "---------------------------------------------------------------------"
  echo "There were $err errors reported timestamping the $1 repositories"
  echo "These errors occurred in the $repo repository(s)"
  echo "The packages in question are:"
  echo $errrpm
  echo "---------------------------------------------------------------------"
  echo ""
else
  echo ""
  echo "---------------------------------------------------------------------"
  echo "SUCESS"
  echo "====================================================================="
  echo "There were no errors reported during the last staging timestamp for"
  echo "$1. You can proceed with patching systems."
  echo "---------------------------------------------------------------------"
  echo ""
fi

# Cleanup temporary files
rm -f /root/bin/repo-names-1*

# Finished
exit 1

