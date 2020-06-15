#!/bin/bash - 
#===============================================================================
#
#          FILE: root_env
# 
#         USAGE: ./root_env 
# 
#   DESCRIPTION: customize linux environment for root on OES2015 SP1
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
#       CREATED: Wed Jul 05 2017 10:27
#   LAST UDATED: Thu Mar 15 2018 14:19
#       VERSION: 0.1.2
#     SCRIPT ID: 077
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.2                                    # version number of the script
sid=077                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=environment                                # email sender
email=root                                       # email recipient(s)
log='/var/log/root_env.log'                      # log name and location (if required)
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

