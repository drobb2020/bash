#!/bin/bash
REL=0.1-2
# This script will do three things:
#	1. Copy the supportutils-plugin-updater to the local server
#	2. Install the package
#	3. Run updateSupportconfig -m to schedule a monthly check for updates
#	4. Run updateSupportconfig to update the local copy of supportconfig

ID=$(whoami)

# ID Check - You must be root
if [ $ID != "root" ]
    then
	echo "You must be root to run this script. Exiting..."
	echo "Please sudo to root and try again."
	sleep 5
	exit 1
fi

# wget the file
/usr/bin/wget http://rnd-s1001.rnd.excession.org/supportutils/supportutils-plugin-updater-rnd-1.0-27.1.noarch.rpm -O /tmp/supportutils-plugin-updater-rnd-1.0-27.1.noarch.rpm
sleep 10

# Install the package
/bin/rpm -Uvh /tmp/supportutils-plugin-updater-rnd-1.0-27.1.noarch.rpm
sleep 4

# Schedule the udpater to run monthly
/sbin/updateSupportutils -m

# Run the updater now
/sbin/updateSupportutils

#Finished
exit 1

