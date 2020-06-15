#!/bin/bash
REL=0.1-3
SID=043
ID=23
##############################################################################
#
#    attr-dir-list.sh - Script to record the directories on an NSS volume that
#                       have rename inhibit and delete inhibit set
#    Copyright (C) 2015  David Robb
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#       Jacques Guillemette (jacques.guillemette@ssc-spc.gc.ca)
#
##############################################################################
# Date Created: Tue Feb 24 09:35:06 2015 
# Last updated: Wed May 27 15:09:57 2015 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog.
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
NSSSBIN=/opt/novell/nss/sbin
NSSROOT=/media/nss

# Get the NSS volume name from the user
echo "--[ NSS Volume Name ]----------------------------"
echo "Please provide the name of the NSS volume"
echo "(in uppercase) you would like to extract"
read -p "the attributes for: " vol
echo "-------------------------------------------------"
echo "The volume is: $vol"
echo "The full path is: $NSSROOT/$vol"

# Extract the file and folder attributes from the NSS DATA volume
$NSSSBIN/attrib $NSSROOT/$vol/* > $NSSROOT/$vol/attribs.txt
cat $NSSROOT/$vol/attribs.txt

cat $NSSROOT/$vol/attribs.txt | grep ri | sed -n -e '/^[^(]*(\([^)]*\)).*/s//\1/p' > $NSSROOT/$vol/dir_list
cat $NSSROOT/$vol/dir_list

rm -f $NSSROOT/$vol/attribs.txt

# Finished
exit 1

