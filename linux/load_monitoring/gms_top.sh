#!/bin/bash - 
#===============================================================================
#
#          FILE: gms_top.sh
# 
#         USAGE: ./gms_top.sh 
# 
#   DESCRIPTION: grab the output of top for Python when GMS is behaving slow
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
#       CREATED: Wed Aug 31 2016 14:33
#  LAST UPDATED: Sun Mar 18 2018 11:03
#       VERSION: 0.1.5
#     SCRIPT ID: 074
# SSC SCRIPT ID: 38
#===============================================================================
# Create gms folder if it does not exist
if [ -d /root/gms ]; then
  echo "gms folder exists, continuing..." > /dev/null
else
  mkdir -p /root/gms
fi

# Get the pid's of Python
pgrep python | grep -v printer | grep -v grep | awk '{ print $2 }' > /root/gms/pids_of_python

# Record what each pid represents
pgrep python | grep -v printer | grep -v grep | awk '{ print $1, $2, $9 }' > /root/gms/gms_pids.txt

# Do a for loop to do 5 top captures for each pid 60 seconds apart.
for (( i=1; i<=5; i++ ))
do
  # Run top for each pid in the file
  pids=$(cat /root/gms/pids_of_python)
  for p in $pids
  do
    # collect top data for each PID and its threads
    top -H -b -n 1 -p "$p" >> /root/gms/gms_top_"$p"-"$i".log
  done

  # tar and bzip all the files for this run
  push .
  cd /root/gms || return
  tar jcf nts_gms_top_files_"$(date +'%y%m%d_%H%M')"-"$i".tbz gms*.log
  popd || return
  clear
  echo ""
  echo "GMS Top Collection"
  echo "-------------------------------"
  echo "Loop #$i completed."
  echo "-------------------------------"
  rm -f /root/gms/gms_top_*.log
  
  # sleep for 60 seconds
  if [ "$i" -lt 5 ]; then
    secs=60
    while [ $secs -ge 0 ]; do
      echo -ne "Next loop starts in: $secs\033[0K\r"
      sleep 1
      : $((secs--))
    done
  fi
done

# Take a gstack of each python pid 10 seconds apart
for (( i=1; i<=5; i++ ))
do
  # Run gstack for each pid in the file
  pids=$(cat /root/gms/pids_of_python)
  for p in $pids
  do
    # collect a gstack for each PID
    /usr/bin/gstack "$p" >> /root/gms/python_gstack_"$p"-"$i".txt
  done

  # tar and bzip all the files for this run
  push .
  cd /root/gms || return
  tar jcf nts_python_gstack_files_"$(date +'%y%m%d_%H%M')"-"$i".tbz python_gstack*.txt
  popd || return
  clear
  echo ""
  echo "GMS gstack Collection"
  echo "-------------------------------"
  echo "Loop #$i completed."
  echo "-------------------------------"
  rm -f /root/gms/python_gstack*.txt
  
  # sleep for 10 seconds
  if [ "$i" -lt 5 ]; then
    secs=10
    while [ $secs -ge 0 ]; do
      echo -ne "Next loop starts in: $secs\033[0K\r"
      sleep 1
      : $((secs--))
    done
  fi
done

# Tar up each of the 5 top runs into a single tarball
push .
cd /root/gms || return
tar jcf nts_gms_top_collection-"$(date +'%y%m%d_%H%M')".tbz gms_pids.txt nts_gms_top_files_*.tbz
popd || return
clear

# tar up each of the 5 gstack runs into a single tarball
push .
cd /root/gms || return
tar jcf nts_gms_gstack_collection-"$(date +'%y%m%d_%H%M')".tbz gms_pids.txt nts_python_gstack*.tbz
popd || return
clear

echo ""
echo "GMS Top Collection Script"
echo "---------------------------------------------------------------"
echo "GMS top collection is complete, you can now reboot the server."
echo "---------------------------------------------------------------"
echo "You will find the collections under /root/gms"
echo "Please provide the tarballs to the DSE."
echo ""

# Cleanup files
rm -f /root/gms/pids_of_python
rm -f /root/gms/gms_pids.txt
rm -f /root/gms/nts_gms_top_files_*.tbz
rm -f /root/gms/nts_python_gstack_files_*.tbz

# Finished
exit 0
