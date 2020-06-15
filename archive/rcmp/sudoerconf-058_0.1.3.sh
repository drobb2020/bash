#!/bin/bash - 
#===============================================================================
#
#          FILE: sudoerconf.sh
# 
#         USAGE: ./sudoerconf.sh 
# 
#   DESCRIPTION: RCMP SUDO configuration script - all regional trees
#
#                Copyright (C) 2015  David Robb
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
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Nov 09 2012 09:55
#  LAST UPDATED: Thu Jul 23 2015 08:03
#      REVISION: 3
#     SCRIPT ID: 058
# SSC SCRIPT ID: ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=058                                     # personal script id number
uid=00                                      # SSC/RCMP script id number
ts=$(date +"%b %d %T")                      # general date/time stamp
ds=$(date +%a)                              # breviated day of the week, eg Mon
df=$(date +%A)                              # full day of the week, eg Monday
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/sudoerconf.log'               # logging (if required)

# Allow Sudo access for ECS
echo "Setting up SUDO access for ECS"

if [ ! -z "$1" ]; then
	echo "# Change requested by ECS" >> $1
	echo "%ECS_ELSS_ADMIN ALL=(ALL) NOPASSWD: ALL" >> $1
else
	export EDITOR=$0
	visudo
fi

exit

