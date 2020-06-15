#!/bin/bash
REL=0.1-1
##############################################################################
#
#    meta-restore.sh - Restore all NSS metadata for the volumes included on the 
#                      command line when you run the script.
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
# Last updated: Wed Oct 03 11:30:41 2012
# Suggested Crontab command: 00 4 * * * /root/bin/meta-backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DOWS=$(date +%a)
DOWF=$(date +%A)

while test -n "$2"
   do
     /sbin/metamig restore "$2" -m a -d < /backup/metadata/$1/$2
     shift
   done

exit

