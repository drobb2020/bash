#!/bin/bash
REL=0.1-02
##############################################################################
#
#    sudoerconf.sh - RCMP SUDO configuration script
#    Copyright (C) 2012  David Robb
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
#
##############################################################################
# Date Created: Fri Nov 09 09:55:42 2012
# Last updated: Fri Nov 09 13:08:29 2012 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# Allow Sudo access for ECS
echo "Setting up SUDO access for ECS"

if [ ! -z "$1" ]; then
	echo "#Change requested by ECS" >> $1
	echo "%ECS_ELSS_ADMIN ALL=(ALL) NOPASSWD: ALL" >> $1
else
	export EDITOR=$0
	visudo
fi

exit

