#!/bin/bash
REL=0.1-02
##############################################################################
#
#    meta-backup.sh - Backup all NSS metadata for the volumes included on the 
#                     command line when you run the script.
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
# Date Created: Tue Oct 02 14:34:02 2012
# Last updated: 
# Suggested Crontab command: 00 4 * * * /root/bin/meta-backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DOWS=$(date +%a)
DOWF=$(date +%A)
HOST=$(hostname)
EMAIL=

while test -n "$1"
   do
     /sbin/metamig save "$1" -m a > /backup/metadata/$DOWS/$1
     shift
   done

exit

