#!/bin/bash - 
#===============================================================================
#
#          FILE: md5sum_cifs.sh
# 
#         USAGE: ./md5sum_cifs.sh 
# 
#   DESCRIPTION: Record the md5 values of critical CIFS files
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
#       CREATED: Thu Jan 28 2016 09:29
#  LAST UPDATED: Thu Jun 16 2016 07:20
#      REVISION: 1
#     SCRIPT ID: 061
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.2
sid=061                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/md5sum_cifs.log'                  # logging (if required)

# Record the md5 sums of critical CIFS files on OES11/OES2015 servers
  /bin/md5sum /usr/lib64/libcifslcm.so > /home/A00212363/md5sum_libcifslcm.so_${host}.txt
  /bin/md5sum /var/opt/novell/eDirectory/data/nmas-methods/CIFSLINLSM_X64 > /home/A00212363/md5sum_CIFSLINLSM_X64_${host}.txt
  /usr/bin/lsof -p `pgrep ndsd` | grep CIFSLINLSM_X64 | wc -l > /home/A00212363/CIFSLINLSM_X64_in_memory_${host}.txt
  /bin/rpm -qa | grep novell-cifs-nmas-methods > /home/A00212363/cifs-nmas_ver_${host}.txt
  /bin/cat /etc/*release | grep -v LSB_VERSION > /home/A00212363/server_ver_${host}.txt

# Finished
exit 1

