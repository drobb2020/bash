#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-config.sh
# 
#         USAGE: ./sc-config.sh 
# 
#   DESCRIPTION: Installation and configuration settings for supportutil tools
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
#       CREATED: Thu Jun 19 2014 10:54
#  LAST UPDATED: Sun Mar 18 2018 11:52
#       VERSION: 0.1.15
#     SCRIPT ID: 054
# SSC SCRIPT ID: 00
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
host=$(hostname)                                 # hostname of the local server
user=$(whoami)                                   # who is running the script

log='/var/log/sc-config.log'                     # log name and location
#===============================================================================

# USER Check - You must be root
if [ $EUID != "root" ]; then
  echo "You must be root to run this script, but you are: $user."
  echo "The script will now exit. Please sudo to root and try again."
  exit 1
fi

# Initialize logging
function initlog() { 
  if [ -e $log ]; then
    echo "log file exists" > /dev/null
  else
    touch $log
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

function logit() { 
  echo -e "$ts" "$host": "$@" >> ${log}
}

initlog

# Install the supportutils-updater package
logit "------------------------------"
logit "Supportutils Updater Package"
logit "------------------------------"
if [ -f /tmp/tools/supportutils-updater-ssc-dev.noarch.rpm ]; then
  echo "Going to install the supportutils updater package to keep supportconfig up-to-date."
  logit "Going to install the supportutils updater package to keep supportconfig up-to-date."
  /bin/rpm -Uvh /tmp/tools/supportutils-updater-ssc-dev.noarch.rpm | tee -a $log
else
  echo "supportutils updater package not found in the expected location."
	echo "Please make sure the appropriate package is in /tmp/tools, and try again."
	logit "supportutils updater package not found in the expected location. Exiting script."
	exit 1
fi

# Check to make sure supportutils was installed
PI=$(rpm -qa | grep supportutils | grep "supportutils-plugin-updater*")
if [ -n "$PI" ]; then
  echo "Updater successfully installed."
  logit "Updater successfully installed."
else
  echo "Package failed to install, please investigate."
  logit "Package failed to install, please investigate."
fi
sleep 2
clear

# Run updateSupportconfig to update all packages
logit "------------------------------"
logit "Run Supportutils Updater"
logit "------------------------------"
echo "Going to update all supportutil packages for the first time."
logit "Going to update all supportutil packages for the first time."
/sbin/updateSupportutils | tee -a $log
echo "The following supportutil packages are now installed on this server:"
logit "The following supportutil packages are now installed on this server:"
/bin/rpm -qa | grep supportutils | tee -a $log
sleep 2
clear

# Schedule a monthly update with cron
logit "------------------------------"
logit "Schedule the Updater"
logit "------------------------------"
echo "Going to schedule a monthly update of all supportutil packages."
logit "Going to schedule a monthly update of all supportutil packages."
/sbin/updateSupportutils -m | tee -a $log
sleep 2
clear

# Create the supportconfig.conf file
logit "---------------------------------------"
logit "Create and configure supportconfig.conf"
logit "---------------------------------------"
if [ -f /etc/supportconfig.conf ]; then
  echo "Configuration file already exists, continuing ..." > /dev/null
else
  /sbin/supportconfig -C
  # Customize supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_COMPANY=/s/"\([^"]*\)"/"Shared Services Canada"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_EMAIL=/s/"\([^"]*\)"/"calvin.hamilton@rcmp-grc.gc.ca"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_NAME=/s/"\([^"]*\)"/"Calvin Hamilton"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_PHONE=/s/"\([^"]*\)"/"613-949-4423"/g' /etc/supportconfig.conf
fi

# Create a custom header file for SSC/RCMP
header=/usr/lib/supportconfig/header.txt
logit "--------------------------------------"
logit "Create custom header for supportconfig"
logit "--------------------------------------"
if [ -f $header ]; then
  logit "The supportconfig header.txt file already exists, continuing..."
else
  echo -e "Shared Services Canada and the Royal Canadian Mounted Police (SSC/RCMP)"; echo -e "Security policy requires that all hostname and IP Addresses information"; echo -e "be removed from all information provided to third-party vendors. If this"; echo -e "supportconfig collection needs to be provided to Novell for additional"; echo -e "analysis please contact the Novell DSE and ask for the sc-clean.sh script."; echo -e "This script removes all hostnames, and IP Addresses from all files in"; echo -e "the supportconfig collection." >> $header
  echo -e "==========================================================================" >> $header
fi
# Create folder for holding the supportconfigs temporarily
logit "---------------------------------------"
logit "Create temp holding folder"
logit "---------------------------------------"
mkdir -p /home/sc_temp
/bin/chown casadmin.users /home/sc_temp

# Create the daily crontab job for root
logit "----------------------------------------"
logit "Create a crontab entry for supportconfig"
logit "----------------------------------------"
crontab -l > sccron
echo "0 2 * * * /sbin/supportconfig -QR /home/sc_temp && /bin/chown casadmin.users /home/sc_temp/nts*" >> sccron
crontab sccron
rm sccron

# Finish
# If SENV is set to 1 go back to the postinstmenu script, otherwise set it to 0 and exit.
if [ -z "$SENV" ]; then
  SENV=0
fi

if [ $SENV == 1 ]; then
  echo "==================================================================="
  echo "Supportconfig Configuration Script"
  echo "-------------------------------------------------------------------"
  echo "This script was executed from the post install menu,"
  echo "now returning to that script."
  echo "-------------------------------------------------------------------"
  logit "This script was executed from the post install menu."
  logit "Automatically returning to that script."
  logit "Supportconfig Configuration Script complete."
  logit "------------------------------------------------------------------"
  . /opt/scripts/os/postinstall/postinstmenu.sh
else
  echo "This script was executed from the command line."
  echo "Script will exit to the terminal prompt."
  logit "This script was executed from the command line."
  logit "Script exited to the terminal prompt."
  logit "Supportconfig Configuration Script complete."
  logit "------------------------------------------------------------------"
  exit 1
fi
