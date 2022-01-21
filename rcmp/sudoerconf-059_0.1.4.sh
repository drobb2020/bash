#!/bin/bash - 
#===============================================================================
#
#          FILE: sudoerconf.sh
# 
#         USAGE: ./sudoerconf.sh 
# 
#   DESCRIPTION: RCMP SUDO configuration script for ATLANTIC Tree
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
#       CREATED: Thu Jul 23 2015 07:44
#  LAST UPDATED: Thu Jul 23 2015 08:05
#      REVISION: 4
#     SCRIPT ID: 059
# SSC SCRIPT ID: ---
#===============================================================================
# Allow sudo access for ECS and SSC
echo "Setting up SUDO access for ECS"

if [ -n "$1" ]; then
	echo "#Change requested by ECS"; "%ECS_ELSS_ADMIN ALL=(ALL) NOPASSWD: ALL"; "%arssc_data_centre ALL=(ALL) NOPASSWD: ALL"  >> "$1"
else
	export EDITOR=$0
	visudo
fi

exit

