#!/bin/bash - 
#===============================================================================
#
#          FILE: attr-dir-list.sh
# 
#         USAGE: ./attr-dir-list.sh 
# 
#   DESCRIPTION: Script to record the directories on an NSS volume that have rename and delete inhibit set
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
#       CREATED: Tue Feb 24 2015 09:35
#  LAST UPDATED: Sun Jun 19 2016 14:19
#      REVISION: 4
#     SCRIPT ID: 043
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.5
sid=043                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/attr-dir-list.log'                # logging (if required)
nsssbin=/opt/novell/nss/sbin                    # path to NSS binaries
nssbase=/media/nss                              # base path for NSS volumes

# Get the NSS volume name from the user
echo "--[ NSS Volume Name ]----------------------------"
echo "Please provide the name of the NSS volume"
echo "(in uppercase) you would like to extract"
read -p "the attributes for: " vol
echo "-------------------------------------------------"
echo "The volume is: $vol"
echo "The full path is: $nssbase/$vol"

# Extract the file and folder attributes from the NSS DATA volume
$nsssbin/attrib $nssbase/$vol/* > $nssbase/$vol/attribs.txt
cat $nssbase/$vol/attribs.txt

cat $nssbase/$vol/attribs.txt | grep ri | sed -n -e '/^[^(]*(\([^)]*\)).*/s//\1/p' > $nssbase/$vol/dir_list
cat $nssbase/$vol/dir_list

rm -f $nssbase/$vol/attribs.txt

# Finished
exit 1

