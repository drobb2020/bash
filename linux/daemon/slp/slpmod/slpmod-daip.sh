#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmod-daip.sh
# 
#         USAGE: ./slpmod-daip.sh 
# 
#   DESCRIPTION: Modify slp.conf file to include new DA Address (IP Format)
#
#                Copyright (c) 2018, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Thu Jan 10 2013 10:10
#  LAST UPDATED: Tue Mar 32 2018 07:56
#       VERSION: 0.1.7
#     SCRIPT ID: 015
# SSC SCRIPT ID: 00
#===============================================================================
RCF=/root/bin/rc-da                      # script run counter
D1=$(/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')                    # ip address of current DA server
DA1=192.168.2.130                        # first new DA server ip address
DA2=192.168.2.131                        # second new DA server ip address 
#===============================================================================

function helpme() { 
  echo ""
  echo "ERROR"
	echo "-------------------------------------------------------"
	echo "The new DA values have not been added to the script."
	echo "Please edit the script and add values for the variables"
	echo "DA1 and DA2, and then run the script again."
	echo "======================================================="
	exit 1
}

if [ -e $RCF ]; then
  . $RCF
    if [ "$RC" = 1 ]; then
      echo ""
      echo "WARNING"
      echo "--------------------------------------------------------"
      echo "This script has already been run once." 
      echo "It is not recommended to run this script multiple times."
      echo "========================================================"
      exit 1
    fi
fi

# Show the current DA's
echo "The current Directory Agent(s) are: $D1"

# Add new DA's
if [ -z $DA1 -o $DA2 ]; then
  echo "The new DA values are missing from the script."
	helpme
else
  sed -i "s/net.slp.DAAddresses = $D1/net.slp.DAAddresses = $D1,$DA1,$DA2/" /etc/slp.conf
fi

# Restart affected daemons
/etc/init.d/slpd stop
/etc/init.d/ndsd restart
/etc/init.d/slpd start

# Show the new scopes
echo "The new Directory Agents are: $(/usr/bin/slptool getproperty net.slp.DAAddresses)"

# Set Run Count for this script
touch $RCF
echo "RC=1" >> $RCF

#Finished
exit 1

