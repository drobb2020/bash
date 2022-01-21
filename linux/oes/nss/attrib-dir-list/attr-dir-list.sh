#!/bin/bash - 
#===============================================================================
#
#          FILE: attr-dir-list.sh
# 
#         USAGE: ./attr-dir-list.sh 
# 
#   DESCRIPTION: Script to record the directories on an NSS volume that have 
#                rename and delete inhibit set
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
#       CREATED: Tue Feb 24 2015 09:35
#  LAST UPDATED: Thu Mar 15 2018 08:24
#       VERSION: 0.1.6
#     SCRIPT ID: 043
# SSC SCRIPT ID: 00
#===============================================================================
nsssbin=/opt/novell/nss/sbin                     # path to NSS binaries
nssbase=/media/nss                               # base path for NSS volumes
#===============================================================================

# Get the NSS volume name from the user
echo "--[ NSS Volume Name ]----------------------------"
echo "Please provide the name of the NSS volume"
echo "(in uppercase) you would like to extract"
read -r -p "the attributes for: " vol
echo "-------------------------------------------------"
echo "The volume is: $vol"
echo "The full path is: $nssbase/$vol"

# Extract the file and folder attributes from the NSS DATA volume
$nsssbin/attrib $nssbase/"$vol"/* > $nssbase/"$vol"/attribs.txt
cat $nssbase/"$vol"/attribs.txt

cat $nssbase/"$vol"/attribs.txt | grep ri | sed -n -e '/^[^(]*(\([^)]*\)).*/s//\1/p' > $nssbase/"$vol"/dir_list
cat $nssbase/"$vol"/dir_list

rm -f $nssbase/"$vol"/attribs.txt

# Finished
exit 0
