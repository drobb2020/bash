#!/bin/bash - 
#===============================================================================
#
#          FILE: slpmodda.sh
# 
#         USAGE: ./slpmodda.sh 
# 
#   DESCRIPTION: Modify slp.conf file to include new DA Address (IP Format)
#
#                Copyright (C) 2016  David Robb
#
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
#  REQUIREMENTS: Remember to populate DA1 and DA2 values in the script
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: Do not cron this script, it should be run manually
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Jan 10 2013 10:10
#  LAST UPDATED: Sun Jun 19 2016 11:50
#      REVISION: 5
#     SCRIPT ID: 015
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.6
sid=015                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/slpmodda.log'                     # logging (if required)
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

