#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmodda.sh
# 
#         USAGE: ./slpmodda.sh 
# 
#   DESCRIPTION: A script to modify slp.conf file to include new DA Address (IP Format)
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
#         NOTES: Remember to populate DA1 and DA2 values in the script
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Jan 10 2013 10:10
#  LAST UPDATED: Mon Jul 20 2015 09:44
#      REVISION: 5
#     SCRIPT ID: 015
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.5
sid=015                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/slpmodda.sh.log'              # logging (if required)
RCF=/root/bin/rc-da
D1=$(/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')
DA1=
DA2=

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
    if [ $RC = 1 ]; then
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
if [ -z ${DA1} -o ${DA2} ]; then
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

