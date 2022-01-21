#!/bin/bash
#===============================================================================
#
#          FILE: smt-mirror.sh
# 
#         USAGE: ./smt-mirror.sh 
# 
#   DESCRIPTION: Script to mirror all configured repositories from NCC or SCC
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
#  LAST UPDATED: Mon Jan 14 2019 09:11
#       VERSION: 1.9
#     SCRIPT ID: 000
# SSC UNIQUE ID: 00
#===============================================================================
rbin='/root/bin'                                # root's bin folder
log='/var/log/smt/smt-mirror.log'               # logging (if required)

# Generate a list of all the Update repositories
/usr/sbin/smt-repos -o -v | grep -B 1 "Repository ID" | sed '/sles-10-x86_64/, +2d' | grep "Repository ID" | awk '{ print $3 }' > $rbin/repo-id

# Script to mirror all configured Update repositories only (no need to re-mirror Pools)
num=$(cat $rbin/repo-id)
for i in $num
  do
    /usr/sbin/smt-mirror -L ${log} --repository "$i"
  done

# Completion message
echo ""
echo "---------------------------------------------------------------------"
echo "SMT Updated - Repositories mirrored from NCC"
echo "---------------------------------------------------------------------"
echo "All configured update repositories have been mirrored down from NCC."
echo "Don't forget to Stage the updated repositories to" 
echo "testing and production."
echo "---------------------------------------------------------------------"
echo "Have fun patching ..."
echo ""

# Cleanup
rm -f $rbin/repo-id

# Finished
exit 1
