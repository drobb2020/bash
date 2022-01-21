#!/bin/bash - 
#===============================================================================
#
#          FILE: cron-config.sh
# 
#         USAGE: ./cron-config.sh 
# 
#   DESCRIPTION: Configure the shell and environment variables for user crontab
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
#       CREATED: Fri Sep 01 2017 15:18
#  LAST UPDATED: Thu Mar 08 2018 09:13
#       VERSION: 0.1.2
#     SCRIPT ID: 066
# SSC SCRIPT ID: 00
#===============================================================================
# Set the shell to bash
echo SHELL=/bin/sh;

# Set the path to the current system environment
echo PATH="$PATH";

# add a space into the file
echo >> ~/bin/tmp.cron

# edit tmp.cron and remove unneeded lines

# Add the contents of the current user's crontab
crontab -l >> tmp.cron

# Import the new modified cron into crontab
crontab tmp.cron

exit 0
