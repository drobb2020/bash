#!/bin/bash
REL=0.1-1

# This script is designed to take a daily supportconfig of a server and send the results to the screpo server

ID=$(whoami)

# ID Check - You must be root
if [ $ID != "root" ]
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
/sbin/supportconfig -Q

# Move the supportconfig to the archive directory
rsync --remove-source-files -r -a -v -e "ssh -l casadmin" --delete /var/log/nts*.* rnd-s1002.rnd.excession.org:/sc-repo

# Finished
exit 1

