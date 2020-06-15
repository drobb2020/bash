#!/bin/bash - 
#===============================================================================
#
#          FILE: 
# 
#         USAGE: ./root_env 
#
#   DESCRIPTION: Set a custom environment for root on OES2015 SP1
#
#                Copyright (c) 2017, David Robb
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
#       CREATED: Wed Jul 05 2017 10:27
#  LAST UPDATED: Wed Jul 05 2017 14:17
#       VERSION: 1
#     SCRIPT ID: 000
# SSC UNIQUE ID: 00
#===============================================================================
version=0.1.1                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC|RCMP script id number
#===============================================================================
ts=$(date +"%b %d %T")                          # general date|time stamp
ds=$(date +%a)                                  # short day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=                                          # email recipient(s)
log='/var/log/root_env.log'		        # logging (if required)
#===============================================================================

# Make sure the user is root
if [ $user != "root" ]; then
	echo "You are not root, script will now exit"
	exit 1
else
	echo "Good you are root" > /dev/null
fi

# Create .local/bin
mkdir -p ~/.local/bin

# Create ~/.bashrc if it doesn't exist
if [ -e ~/.bashrc ]; then
  touch ~/.bashrc
fi

# Populate ~/.bashrc
echo "export NCURSES_NO_UTF8_ACS=1" >> ~/.bashrc
echo -e "PATH=\$PATH:\$HOME/.local/bin:\$HOME/bin:/usr/sbin/" >> ~/.bashrc
echo "export PATH" >> ~/.bashrc

# Update the environment
source ~/.bashrc

# Finished
exit 1

