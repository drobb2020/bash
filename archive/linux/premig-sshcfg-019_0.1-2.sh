#!/bin/bash
REL=0.1-2
SID=019
##############################################################################
#
#    premig-sshcfg.sh - ssh configuration to allow printer migrations
#    Copyright (C) 2014  David Robb
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
# Date Created: Tue May 27 10:21:15 2014 
# Last updated: Wed May 27 12:27:35 2015 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################

# SSH Configuration
echo "--[ Notice ]----------------------------------"
echo "Updating SSH configuration"
echo "Going to temporarily allow root login via ssh."
echo "=============================================="
sleep 2

PRL0=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")
echo -e "$PRL0" > /tmp/prl0.tmp.$$
if [ -n "$(cat /tmp/prl0.tmp.$$)" ]
    then
	# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
	sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
	RESTARTSSH=true
    else
	echo "The setting PermitRootLogin has already been set to Yes, no further action taken."
fi

P1=$(cat /etc/ssh/ssh_config | grep -w Port | grep -v "#")
echo -e "$P1" > /tmp/p1.tmp.$$
if [ -z "$(cat /tmp/p1.tmp.$$)" ]
    then
	echo "Port 3479" >> /etc/ssh/ssh_config
    else
	echo "The ssh client port setting has already been made, no further action taken."
fi

if  $RESTARTSSH ; 
    then
	/etc/init.d/sshd restart
fi

# Clean up temporary files in /tmp
# rm -f /tmp/*.tmp.$$

exit 1

