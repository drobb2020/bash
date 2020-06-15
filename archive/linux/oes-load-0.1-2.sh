#!/bin/bash
REL=0.1-2
##############################################################################
#
#    oesload.sh - check and log the logon load of an OES2 server
#    Copyright (C) 2012  David Robb, drobb@novell.com
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
##############################################################################
# Date Created: Tue Mar 22 11:53:52 EDT 2011
# Last updated: Mon Apr 16 13:48:30 2012 
# Crontab command: sample every 15 minutes
# Supporting file: /var/log/oesusers.log
# Additional Notes: 
##############################################################################
# Declare variables
DTSTAMP=$(date +"%b %d %T")
inloggade=`ncpcon connection list | grep CN | grep -v NOT | grep -v workstations | cut -f 2 | sort | uniq -i | grep -v [*] | wc -l`

# In grep -v computerou replace computerou with the name fo the container where you store your workstations
load=`top -b -n 1 | grep Cpu | cut -f 3 -d " " | cut -f 1 -d "%"`

echo $DTSTAMP, No. of Users - $inloggade, Proc Load - $load >> /var/log/oes-logon-load.log
exit

