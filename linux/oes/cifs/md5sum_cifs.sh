#!/bin/bash - 
#===============================================================================
#
#          FILE: md5sum_cifs.sh
# 
#         USAGE: ./md5sum_cifs.sh 
#
#   DESCRIPTION: 
#
#                Copyright (c) 2016, David Robb
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
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Mon Oct 31 2016 13:38
#       UPDATED: Mon Oct 31 2016 13:49
#       VERSION: 3
#     SCRIPT ID: 061
# SSC UNIQUE ID: 00
#===============================================================================
host=$(hostname)                                # host name of local server
home=$(pwd)                                     # current working directory
file=cifs_critical_files_$1_${host}.txt         # report file name

# Collect data about cifs
  echo ""
  echo -e "\e[1;37mCIFS Critical Files Check Report\e[0m"
  echo "CIFS Critical Files Check Report" >> "$home"/"$file"
  echo -e "\e[1;37m-----------------------------------------------------------\e[0m"
  echo "-----------------------------------------------------------" >> "$home"/"$file"
  echo -e "\e[1;37mThe md5sum for the cifs library file is:\e[0m" 
  /bin/md5sum /usr/lib64/libcifslcm.so

  echo "The md5sum for the cifs library file is:" >> "$home"/"$file"
  /bin/md5sum /usr/lib64/libcifslcm.so >> "$home"/"$file"

  echo -e "\e[1;37mThe md5sum for CIFSLINLSM_X64 is:\e[0m" 
  /bin/md5sum /var/opt/novell/eDirectory/data/nmas-methods/CIFSLINLSM_X64

  echo ""; echo "The md5sum for CIFSLINLSM_X64 is: "; /bin/md5sum /var/opt/novell/eDirectory/data/nmas-methods/CIFSLINLSM_X64 >> "$home"/"$file"

  echo -e "\e[1;37mCIFSLINLSM_X64 is loaded in memory (0=no, 1=yes):\e[0m"; /usr/bin/lsof -p "$(pgrep ndsd)" | grep -c CIFSLINLSM_X64

  echo ""; echo "CIFSLINLSM_X64 is loaded in memory (0=no, 1=yes):"; /usr/bin/lsof -p "$(pgrep ndsd)" | grep -c CIFSLINLSM_X64 >> "$home"/"$file"

  echo -e "\e[1;37mThe installed version of the cifs nmas method is:\e[0m"; /bin/rpm -qa | grep novell-cifs-nmas-methods

  echo ""; echo "The installed version of the cifs nmas method is: "; /bin/rpm -qa | grep novell-cifs-nmas-methods >> "$home"/"$file"

  echo -e "\e[1;37mThe server version is:\e[0m"; /bin/cat /etc/*release

  echo ""; echo "The server version is: "; /bin/cat /etc/*release >> "$home"/"$file"

# Finished
exit 0
