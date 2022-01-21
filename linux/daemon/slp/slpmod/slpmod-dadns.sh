#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmod-dadns.sh
# 
#         USAGE: ./slpmod-dadns.sh 
# 
#   DESCRIPTION: Modify the slp.conf file to include new DA Addresses (DNS format)
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
#       CREATED: Mon Jul 20 2015 09:48
#  LAST UPDATED: Mon Mar 12 2018 12:30
#       VERSION: 0.1.7
#     SCRIPT ID: 016
# SSC SCRIPT ID: 00
#===============================================================================
RCF=/root/bin/rc-da-dns
DA0=$(/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')
DA1=
DA2=
DA3=
#===============================================================================

function helpme() { 
  echo ""
  echo "ERROR"
	echo "-------------------------------------------------------"
	echo "The new DA values have not been added to the script."
	echo "Please edit the script and add values for the variables"
	echo "DA1, DA2 and DA3, and then run the script again."
	echo "======================================================="
	exit 1
}

if [ -e $RCF ]; then
  . $RCF
    if [ "$RC" = 1 ]; then
      echo "WARNING"
      echo "--------------------------------------------------------"
      echo "This script has already been run once." 
      echo "It is not recommended to run this script multiple times."
      echo "========================================================"
      exit 1
    fi
fi

# Show the current DA's
echo "The current Directory Agent(s) are: $DA0"

# Add new DA's
if [ -z "$DA1" -o "$DA2" -o "$DA3" ]; then
  echo "The new DA values are missing from the script."
	helpme
else
  sed -i "s/net.slp.DAAddresses = $DA0/net.slp.DAAddresses = $DA1,$DA2,$DA3/" /etc/slp.conf
fi
# Restart affected daemons
	/usr/sbin/rcslpd restart
	/usr/sbin/ndsd restart

# Show the new scopes
echo "The new Directory Agents are: $(/usr/bin/slptool getproperty net.slp.DAAddresses)"

# Set Run Count for this script
touch $RCF
echo "RC=1" >> $RCF

#Finished
exit 1

