#!/bin/bash
#===============================================================================
#
#          FILE: smt-staging
# 
#         USAGE: ./smt-staging
# 
#   DESCRIPTION: Script to stage SMT repositories to testing and production
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENts: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: 
#  LAST UPDATED: Wed Sep 01 2021 11:34
#       VERSION: 0.2.5
#     SCRIPT ID: ---
#===============================================================================
ts=$(date +"%b %d %T")            # general date/time stamp
host=$(hostname)                  # host name of local server
user=$(whoami)                    # who is running the script
rbin='/root/bin'                  # binary folder for running commands and storing files
log='/var/log/smt/smt-staging.log' # logging (if required)

function initlog() { 
  rm -f ${log}
  touch ${log}
  chown smt.www ${log}
  chmod 600 ${log}
  {
    echo -e "Logging started at ${ts}"
    echo -e "The script was initiated by ${user}"
    echo -e "The script is owned by smt:www"
    echo -e ""
  } >> ${log}
}

function logit() { 
  echo -e "$ts" "$host" "$@" >> ${log}
}

initlog

# Uncomment these lines for testing changes to the process
# /usr/sbin/smt-repos -o -v | grep "[*]" > $rbin/all-repos.txt
# exit 1

# get the repository names for all sle-15-x86_64
/usr/sbin/smt-repos -o -v | grep "[*]" | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v sle-11-x86_64 | grep -v sle-12-x86_64 | grep -v RES7 | awk '{ print $4 }' > $rbin/repo-names-15
echo ">>> sle-15-x86_64 repository list generated"
echo ""

# Get the repository names for all sle-12-x86_64
/usr/sbin/smt-repos -o -v | grep "[*]" | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v sle-11-x86_64 | grep -v sle-15-x86_64 | grep -v RES7 | awk '{ print $4 }' > $rbin/repo-names-12
echo ">>> sle-12-x86_64 repository list generated"
echo ""

# Get the repository names for all sle-11-x86_64
/usr/sbin/smt-repos -o -v | grep "[*]" | grep -v sle-12-x86_64 | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v sle-15-x86_64 | grep -v RES7 | awk '{ print $4 }' > $rbin/repo-names-11
echo ">>> sle-11-x86_64 repository list generated"
echo ""

# Get the repository names for all RES7 x86_64
/usr/sbin/smt-repos -o -v | grep "[*]" | grep -v sle-12-x86_64 | grep -v sles-10-x86_64 | grep -v sles-10-i586 | grep -v sle-15-x86_64 | grep -v sle-11-x86_64 | awk '{ print $4 }'> $rbin/repo-names-res7
echo ">>> RES7 x86_64 repository list generated"
echo ""

# Get the repository names for all sles-10-x86_64
/usr/sbin/smt-repos -o -v | grep "[*]" | grep -v sle-12-x86_64 | grep -v sle-11-x86_64 | grep -v sles-10-i586 | grep -v sle-15-x86_64 | grep -v RES7 | awk '{ print $4 }' > $rbin/repo-names-10
echo ">>> sles-10-x86_64 repository list generated"
echo ""

# Get the repository names for all sles-10-i586
/usr/sbin/smt-repos -o -v | grep "[*]" | grep -v sle-12-x86_64 | grep -v sle-11-x86_64 | grep -v sles-10-x86_64 | grep -v sle-15-x86_64 | grep -v RES7 | awk '{ print $4 }' > $rbin/repo-names-10_i586
echo ">>> sles-10-i586 repository list generated"

clear

# Exit is here for testing purposes only!
# exit 1

echo ""
echo "---------------------------------------------------------------------"
echo "PROGRESS"
echo "====================================================================="
echo "The testing repositories are being timestamped. All progress (success"
echo "and errors) is being written to $log."
echo "An error report (if any) will be generated once the script completes."
echo "---------------------------------------------------------------------"
echo ""

# timestamp all testing repositories so patches can be installed
echo "Time stamping testing repositories." 
echo "Any errors will be reported at the end of the process."
echo ""
list1=$(cat $rbin/repo-names-10_i586)
for repo1 in $list1
  do 
    /usr/sbin/smt-staging -L $log createrepo "$repo1" 'sles-10-i586' --testing
  done

list2=$(cat $rbin/repo-names-10)
for repo2 in $list2
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo2" 'sles-10-x86_64' --testing
  done

list3=$(cat $rbin/repo-names-11)
for repo3 in $list3
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo3" 'sle-11-x86_64' --testing
  done

list4=$(cat $rbin/repo-names-12)
for repo4 in $list4
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo4" 'sle-12-x86_64' --testing
  done
list5=$(cat $rbin/repo-names-15)
for repo5 in $list5
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo5" 'sle-15-x86_64' --testing
  done
list6=$(cat $rbin/repo-names-res7)
for repo6 in $list6
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo6" 'x86_64' --testing
  done

# timestamp all production repositories so patches can be installed
echo "Time stamping production repositories." 
echo "Any errors will be reported at the end of the process."
echo ""

list1=$(cat $rbin/repo-names-10_i586)
for repo1 in $list1
  do 
    /usr/sbin/smt-staging -L $log createrepo "$repo1" 'sles-10-i586' --production
  done

list2=$(cat $rbin/repo-names-10)
for repo2 in $list2
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo2" 'sles-10-x86_64' --production
  done

list3=$(cat $rbin/repo-names-11)
for repo3 in $list3
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo3" 'sle-11-x86_64' --production
  done

list4=$(cat $rbin/repo-names-12)
for repo4 in $list4
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo4" 'sle-12-x86_64' --production
  done
list5=$(cat $rbin/repo-names-15)
for repo5 in $list5
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo5" 'sle-15-x86_64' --production
  done
list6=$(cat $rbin/repo-names-res7)
for repo6 in $list6
  do
    /usr/sbin/smt-staging -L $log createrepo "$repo6" 'x86_64' --production
  done

# Completion message
clear

err=$(grep -ciw "Checksum mismatch' (Try 3)" /var/log/smt/smt-staging.log)

if [ "${err}" -gt 0 ]; then
  echo ""
  echo "---------------------------------------------------------------------"
  echo "ERROR REPORT"
  echo "====================================================================="
  echo "The following repository(s) generated an error while being"
  echo "staged for testing and production."
  echo "Please correct these error(s):"
  
  repo=$(grep -iw "Checksum mismatch' (Try 3)" /var/log/smt/smt-staging.log | awk -F/ '{ print $8, $9}' | uniq | sort)
        
	errrpm=$(grep -iw "Checksum mismatch' (Try 3)" /var/log/smt/smt-staging.log | awk '{ print $7 }' | awk -F/ '{ print $12 }' | sed "s/'//g" | sed 's/://g')
  
  echo "---------------------------------------------------------------------"
  echo "There were $err errors reported staging the testing and production repositories"
  echo "These errors occurred in the $repo repository(s)"
  echo "The packages in question are:"
  echo "$errrpm"
  echo "---------------------------------------------------------------------"
  echo ""
else
  echo ""
  echo "---------------------------------------------------------------------"
  echo "SUCCESS"
  echo "====================================================================="
  echo "There were no errors reported during the last staging timestamp for"
  echo "testing and production. You can proceed with patching systems."
  echo "---------------------------------------------------------------------"
  echo ""
fi
sleep 2

# Cleanup temporary files
rm -f $rbin/repo-*

# Finished
exit 0
