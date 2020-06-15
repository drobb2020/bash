#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmodda-dns.sh
# 
#         USAGE: ./slpmodda-dns.sh 
# 
#   DESCRIPTION: A script to modify the slp.conf file to include new DA Addresses (DNS format)
#
#                Copyright (C) 2015  David Robb
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: Remember to set the custom variables for your environment
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Mon Jul 20 2015 09:48
#  LAST UPDATED: Mon Jul 20 2015 09:55
#      REVISION: 5
#     SCRIPT ID: 016
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.5
sid=016                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/slpmodda-dns.log'             # logging (if required)
RCF=/root/bin/rc-da-dns
DA0=$(/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')
DA1=
DA2=
DA3=

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
    if [ $RC = 1 ]; then
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
if [ -z ${DA1} -o ${DA2} -o ${DA3} ]; then
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

