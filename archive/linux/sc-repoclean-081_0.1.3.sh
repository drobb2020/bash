#!/bin/bash
REL=0.1.3

##############################################################################
#
#    sc-repoclean.sh - This script is used to cleanup the supportconfig 
#                      repository of any supportconfig collections older than 
#                      7 days
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
# Date Created: Thu Jan 08 09:30:17 2015 
# Last updated: Wed Dec 16 11:01:33 2015 
# Crontab command: Not recommended - run only as directed by your xSE
# Supporting file: None
# Additional notes: 
##############################################################################
HOST=$(hostname)
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=calvin.hamilton@rcmp-grc.gc.ca,jacques.guillemette@ssc-spc.gc.ca,david.robb@rcmp-grc.gc.ca,root

# sc-repoclean.sh  - delete any supportconfigs older than 7 days

# Use find to create a list of old supportconfigs to delete and delete them
/usr/bin/find /opt/supportconf/repo -maxdepth 1 -type f -mtime +6 -exec rm -f {} \;

# finished
exit 1

