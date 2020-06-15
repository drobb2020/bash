#!/bin/bash
REL=0.1.1
ID=23
##############################################################################
#
#    sc-ryncn.sh - This script is used to move new supportconfigs from servers
#                  to the repository server
#    Copyright (C) 2015  David Robb
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
#       Jacques Guillemette (jacques.guillemette@ssc-spc.gc.ca)
#
##############################################################################
# Date Created: Thu Jan 07 14:30:17 2015 
# Last updated: Wed Feb 04 08:24:33 2015 
# Crontab command: Daily at 0700
# Supporting file: None
# Additional notes: 
##############################################################################
HOST=$(hostname)
TS=$(date +"%b %d %T")
USER=$(whoami)
SERVERS=$(cat /opt/scripts/os/servers.txt)

# Run the ldap server list script to update the list of servers.
# . /opt/scripts/os/national/maintenance/ldapserver.sh

# Go through each server in the list and collect the supportconfigs
for s in $SERVERS 
  do
    rsync --remove-source-files -a casadmin@$s.ross.rossdev.rcmp-grc.gc.ca:/home/sc_temp/nts* /opt/supportconf/repo/
  done

# Finished
exit 1

