#!/bin/bash
REL=0.1-2
##############################################################################
#
#    postmig-sshcfg.sh - reset ssh configuration to DSB defaults
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
# Last updated: Tue May 27 14:27:35 2014 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################

PRL0=$(cat /etc/ssh/sshd_config | grep -w PermitRootLogin | grep -v "#")
echo -e "$PRL0" > /tmp/prl0.tmp.$$
if [ -n "$(cat /tmp/prl0.tmp.$$)" ]
    then
	# echo "PermitRootLogin no" >> /etc/ssh/sshd_config
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	RESTARTSSH=true
    else
	echo "The setting PermitRootLogin has already been set to NO, no further action taken."
fi

if  $RESTARTSSH ; 
    then
	/etc/init.d/sshd restart
fi

# Clean up temporary files in /tmp
rm -f /tmp/*.tmp.$$

exit 1



