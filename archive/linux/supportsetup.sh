#!/bin/bash
REL=0.1-4
##############################################################################
#
#    supportsetup.sh - Installs and updates supportconfig tools for the first
#                      time.
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
# Last Updated: Mon Jun 23 13:10:30 2014 
# Company: Novell Inc.
# Crontab command: Not recommended
# Supporting file: 
# Additional notes: 
##############################################################################
HOST=$(hostname)
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
LOG="/var/log/postinstall.log"

# USER Check - You must be root
if [ $USER != "root" ]
    then
	echo "You must be root to run this script, but you are: $USER."
	echo "The script will now exit. Please sudo to root and try again."
	sleep 3
	exit 1
fi

function initlog() { 
   if [ -e /var/log/postinstall.log ]
	then
		echo "log file exists" > /dev/null
	else
		touch /var/log/postinstall.log
		echo "Logging started at ${TS}" > ${LOG}
		echo "All actions are being performed by the user: ${USER}" >> ${LOG}
		echo " " >> ${LOG}
    fi
}

function logit() { 
	echo -e $TS $HOST: $* >> ${LOG}
}

initlog

# Install the supportutils-updater package
logit "------------------------------"
logit "Supportutils Updater Package"
logit "------------------------------"
echo "Going to install the supportutils updater package to keep supportconfig up-to-date."
logit "Going to install the supportutils updater package to keep supportconfig up-to-date."
/bin/rpm -Uvh /tmp/tools/supportutils-updater-ssc.noarch.rpm | tee -a $LOG

# Check to make sure it was installed
PI=$(rpm -qa | grep supportutils | grep supportutils-plugin-updater*)
if [ -n $PI ]
    then
	echo "Updater successfully installed."
	logit "Updater successfully installed."
    else
	echo "Package failed to install, please investigate."
	logit "Package failed to install, please investigate."
fi
sleep 10
clear

# Run updateSupportconfig for the first time
logit "------------------------------"
logit "Run Supportutils Updater"
logit "------------------------------"
echo "Going to update all supportutil packages for the first time."
logit "Going to update all supportutil packages for the first time."
/sbin/updateSupportutils | tee -a $LOG
echo "The following supportutil pacages are now installed on this server:"
logit "The following supportutil pacages are now installed on this server:"
/bin/rpm -qa | grep supportutils | tee -a $LOG
sleep 10
clear

# Schedule a monthly update with cron
logit "------------------------------"
logit "Schedule the Updater"
logit "------------------------------"
echo "Going to schedule a monthly update of all supportutil packages."
logit "Going to schedule a monthly update of all supportutil packages."
/sbin/updateSupportutils -m | tee -a $LOG
sleep 10
clear

# Finished
if [ $SENV == 1]
    then
	. /opt/scripts/os/postinstall/postinstmenu.sh
    else
	exit 1
fi


