#!/bin/bash
REL=0.01-04
##############################################################################
#
#    slpmod.sh - A script to modify the slp.conf file on a server to include
#                a new DA Address
#    Copyright (C) 2013  David Robb
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
# Date Created: Thu Jan 10 10:10:03 2013 
# Last updated: Tue Jan 15 07:43:51 2013 
# Crontab command: Not recommended
# Supporting file: 
# Additional notes: Remember to set the custom variables for your environment
##############################################################################
# Declare variables
RCF=/root/bin/rc-da
D1=$(/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')
DA1=10.110.0.80
DA2=10.110.0.81

if [ -e $RCF ]
    then
	. $RCF
	if [ $RC = 1 ]
	    then
		echo "This script has already been run once." 
		echo "It is not recommended to run this script multiple times."
		exit 1
	fi
fi

# Show the current DA's
echo "The current Directory Agent(s) are: $D1"

# Add new DA's
sed -i "s/net.slp.DAAddresses = $D1/net.slp.DAAddresses = $D1,$DA1,$DA2/" /etc/slp.conf

# Restart affected daemons
	/etc/init.d/slpd restart
	/etc/init.d/ndsd restart

# Show the new scopes
echo "The new Directory Agents are: $(/usr/bin/slptool getproperty net.slp.DAAddresses)"

# Set Run Count for this script
touch $RCF
echo "RC=1" >> $RCF

#Finished
exit
