#!/bin/bash
REL=0.1-3
##############################################################################
#
#    sc-daily.sh - This script is designed to take a daily supportconfig of 
#                  a server
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
# Date Created: Thu Jun 19 10:54:02 2014 
# Last Updated: Tue Aug 12 10:28:20 2014 
# Company: Novell Inc.
# Crontab command: 0 2 0 0 0 root /opt/scripts/os/national/maintenance/sc-daily.sh
# Supporting file: None
# Additional notes:
##############################################################################
HOST=$(hostname)
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)

# ID Check - You must be root
if [ $USERR != "root" ]
    then
	echo "You must be root to run this script. Exiting..."
	echo "Please sudo to root and try again."
	sleep 5
	exit 1
fi

# Create the supportconfig.conf file on the very first run
if [ -f /etc/supportconfig.conf ]
    then
	echo "Configuration file already exists, continuing ..." > /dev/null
    else
	/sbin/supportconfig -C
	# Customize supportconfig.conf
	sed -i 's/VAR_OPTION_CONTACT_COMPANY='""'/VAR_OPTION_CONTACT_COMPANY="Royal Canadian Mounted Police"/g' /etc/supportconfig.conf
	sed -i 's/VAR_OPTION_CONTACT_EMAIL='""'/VAR_OPTION_CONTACT_EMAIL="jacques.guillemette@ssc-spc.gc.ca"/g' /etc/supportconfig.conf
	sed -i 's/VAR_OPTION_CONTACT_NAME='""'/VAR_OPTION_CONTACT_NAME="Jacques Guillemette"/g' /etc/supportconfig.conf
	sed -i 's/VAR_OPTION_CONTACT_PHONE='""'/VAR_OPTION_CONTACT_PHONE="613-993-1260"/g' /etc/supportconfig.conf
fi

# Create a custom header file for SSC/RCMP
if [ -f /usr/lib/supportconfig/header.txt ]
    then
	echo "The header.txt file already exists, continuing..." > /dev/null
    else
	echo -e "Shared Services Canada and the Royal Canadian Mounted Police (SSC/RCMP)" >> /usr/lib/supportconfig/header.txt
	echo -e "Security policy requires that all hostname and IP Addresses information" >> /usr/lib/supportconfig/header.txt
	echo -e "be removed from all information provided to third-party vendors. If this" >> /usr/lib/supportconfig/header.txt
	echo -e "supportconfig collection needs to be provided to Novell for additional" >> /usr/lib/supportconfig/header.txt
	echo -e "analysis please contact the Novell DSE and ask for the sc-clean.sh script." >> /usr/lib/supportconfig/header.txt
	echo -e "This script removes all hostnames, and IP Addresses from all files in" >> /usr/lib/supportconfig/header.txt
	echo -e "the collection." >> /usr/lib/supportconfig/header.txt
	echo -e "==========================================================================" >> /usr/lib/supportconfig/header.txt
fi

# Run a daily supportconfig 
clear
/sbin/supportconfig -QR /home/casadmin/

# Take ownership of the nts files
/bin/chown casadmin.users *.tbz
/bin/chown casadmin.users *.md5

# Finished
exit 1

