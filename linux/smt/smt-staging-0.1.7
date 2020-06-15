#!/bin/bash - 
#===============================================================================
#
#          FILE: smt-staging
# 
#         USAGE: ./smt-staging 
# 
#   DESCRIPTION: stage updated repositories to testing and prodcution
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
#       CREATED: Mon Jun 19 2017 07:54
#   LAST UDATED: Sun Mar 18 2018 11:31
#       VERSION: 0.1.7
#     SCRIPT ID: 080
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.7                                    # version number of the script
sid=080                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=smt-sync                                   # email sender
email=root                                       # email recipient(s)
log='/var/log/smt/smt-staging.log'               # log name and location (if required)
#===============================================================================

# Initialize logging
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
  echo "The expected syntax is: ./smt-staging [testing | production]"
  echo "For example: ./smt-staging production"
  echo "The script will now exit, please try again."
  echo "---------------------------------------------------------------------"
  echo ""
  echo ""
  exit 1
}

# initlog

# Build the list of repositories base on OS architecture
if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line."
  helpme
else
  # Get the repository names for all sle-12-x86_64 repositorues
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v sle-11-x86_64 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-12
  echo "sle-12-x86_64 repository list has been generated"
  echo ""

  # Get the repository names for all sle-11-x86_64 repositories
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sle-12-x86_64 | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-11
  echo "sle-11-x86_64 repository list has been generated"
  echo ""

  # Get the repository names for all sles-10-x86_64 repositories
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sle-12-x86_64 | grep -v sle-11-x86_64 | grep -v sles-10-i586 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-10
  echo "sles-10-x86_64 repository list has been generated"
  echo ""

  # Get the repository names for all sles-10-i586 repositories
  /usr/sbin/smt-repos -o -v | grep [*] | grep -v sle-12-x86_64 | grep -v sle-11-x86_64 | grep -v sles-10-x86_64 | grep -v Perl | grep -v php | grep -v Python | awk '{ print $5 }' > /root/bin/repo-names-10_i586
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
      /usr/sbin/smt-staging -L $log createrepo $repo1 'sle-11-x86_64' --$1
    done
  list2=$(cat /root/bin/repo-names-10)
  for repo2 in $list2
    do
      /usr/sbin/smt-staging -L $log createrepo $repo2 'sles-10-x86_64' --$1
    done
  list3=$(cat /root/bin/repo-names-10_i586)
  for repo3 in $list3
    do
      /usr/sbin/smt-staging -L $log createrepo $repo3 'sles-10-i586' --$1
    done
  list4=$(cat /root/bin/repo-names-12)
  for repo4 in $list4
    do
      /usr/sbin/smt-staging -L $log createrepo $repo4 'sle-12-x86_64' --$1
    done
fi

# Completion message
clear
err=$(cat /var/log/smt/smt-staging.log | grep -i 'checksum mismatch' | wc -l)
if [ ${err} -gt 0 ]; then
  echo ""
  echo "---------------------------------------------------------------------"
  echo "ERROR REPORT"
  echo "====================================================================="
  echo "The following repository(s) generated an error while being"
  echo "staged for $1."
  echo "Please correct these error(s) before timestamping for production"
        repo=$(cat /var/log/smt/smt-timestamp.log | grep -i 'checksum mismatch' | awk -F/ '{ print $8, $9}' | uniq | sort)
        errrpm=$(cat /var/log/smt/smt-timestamp.log | grep -i 'checksum mismatch' | awk -F/ '{ print $12}')
  echo "---------------------------------------------------------------------"
  echo "There were $err errors reported staging the $1 repositories"
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
  echo "$1. You can proceed with patching $1 systems."
  echo "---------------------------------------------------------------------"
  echo ""
fi
sleep 2

# Cleanup temporary files
rm -f /root/bin/repo-names-1*

# Finished
exit 1

