#!/bin/bash - 
#===============================================================================
#
#          FILE: bkup-rsync.sh
# 
#         USAGE: ./bkup-rsync.sh 
# 
#   DESCRIPTION: Rsync backup script to move previously created backup files
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
#       CREATED: Tue Jan 26 2016 11:36
#  LAST UPDATED: Thu Mar 08 2018 09:26
#       VERSION: 0.1.4
#     SCRIPT ID: 060
# SSC SCRIPT ID: 00
#===============================================================================
# Move backup files to a common location
rsync --remove-source-files -a casadmin@"$1":/home/backup/backup_* /home/backup

exit 0
