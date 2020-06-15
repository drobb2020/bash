#!/bin/bash
REL=0.1-13
SID=051
ID=10
##############################################################################
#
#    sc-config.sh - This script is designed to take a daily supportconfig of 
#                  a server and send the results to the screpo server
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
# Last Updated: Thu May 28 08:36:08 2015 
# Company: Novell Inc.
# Crontab command: 0 2 0 0 0 root /opt/scripts/os/national/maintenance/sc-daily.sh
# Supporting file: None
# Additional notes:
##############################################################################
HOST=$(hostname)
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
LOG="/var/log/postinstall.log"

# USER Check - You must be root
if [ $USER != "root" ]; then
  echo "You must be root to run this script, but you are: $USER."
  echo "The script will now exit. Please sudo to root and try again."
  sleep 2
  exit 1
fi

function initlog() { 
  if [ -e /var/log/postinstall.log ]; then
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
/bin/rpm -Uvh /tmp/tools/supportutils-updater-ssc-dev.noarch.rpm | tee -a $LOG

# Check to make sure it was installed
PI=$(rpm -qa | grep supportutils | grep supportutils-plugin-updater*)
if [ -n $PI ]; then
  echo "Updater successfully installed."
  logit "Updater successfully installed."
else
  echo "Package failed to install, please investigate."
  logit "Package failed to install, please investigate."
fi
sleep 2
clear

# Run updateSupportconfig for the first time
logit "------------------------------"
logit "Run Supportutils Updater"
logit "------------------------------"
echo "Going to update all supportutil packages for the first time."
logit "Going to update all supportutil packages for the first time."
/sbin/updateSupportutils | tee -a $LOG
echo "The following supportutil packages are now installed on this server:"
logit "The following supportutil packages are now installed on this server:"
/bin/rpm -qa | grep supportutils | tee -a $LOG
sleep 2
clear

# Schedule a monthly update with cron
logit "------------------------------"
logit "Schedule the Updater"
logit "------------------------------"
echo "Going to schedule a monthly update of all supportutil packages."
logit "Going to schedule a monthly update of all supportutil packages."
/sbin/updateSupportutils -m | tee -a $LOG
sleep 5
clear

# Create the supportconfig.conf file on the very first run
logit "---------------------------------------"
logit "Create and configure supportconfig.conf"
logit "---------------------------------------"
if [ -f /etc/supportconfig.conf ]; then
  echo "Configuration file already exists, continuing ..." > /dev/null
else
  /sbin/supportconfig -C
  # Customize supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_COMPANY=/s/"\([^"]*\)"/"Shared Services Canada"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_EMAIL=/s/"\([^"]*\)"/"jacques.guillemette@ssc-spc.gc.ca"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_NAME=/s/"\([^"]*\)"/"Jacques Guillemette"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_PHONE=/s/"\([^"]*\)"/"613-993-1260"/g' /etc/supportconfig.conf
fi

# Create a custom header file for SSC/RCMP
logit "--------------------------------------"
logit "Create custom header for supportconfig"
logit "--------------------------------------"
if [ -f /usr/lib/supportconfig/header.txt ]; then
  echo "The header.txt file already exists, continuing..." > /dev/null
else
  echo -e "Shared Services Canada and the Royal Canadian Mounted Police (SSC/RCMP)" >> /usr/lib/supportconfig/header.txt
  echo -e "Security policy requires that all hostname and IP Addresses information" >> /usr/lib/supportconfig/header.txt
  echo -e "be removed from all information provided to third-party vendors. If this" >> /usr/lib/supportconfig/header.txt
  echo -e "supportconfig collection needs to be provided to Novell for additional" >> /usr/lib/supportconfig/header.txt
  echo -e "analysis please contact the Novell DSE and ask for the sc-clean.sh script." >> /usr/lib/supportconfig/header.txt
  echo -e "This script removes all hostnames, and IP Addresses from all files in" >> /usr/lib/supportconfig/header.txt
  echo -e "the supportconfig collection." >> /usr/lib/supportconfig/header.txt
  echo -e "==========================================================================" >> /usr/lib/supportconfig/header.txt
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
if [ -z $SENV ]; then
  SENV=0
fi

if [ $SENV == 1 ]; then
  echo "==================================================================="
  echo "V$REL Supportconfig Conifugration Script"
  echo "-------------------------------------------------------------------"
  echo "This script was executed from the post install menu,"
  echo "now returning to that script."
  echo "-------------------------------------------------------------------"
  logit "This script was executed from the post install menu."
  logit "Automatically returning to that script."
  logit "V$REL Supportconfig Conifugration Script complete."
  logit "-------------------------------------------------------------------"
  . /opt/scripts/os/postinstall/postinstmenu.sh
else
  echo "This script was executed from the command line."
  echo "Script will exit to the terminal prompt."
  logit "This script was executed from the command line."
  logit "Script exited to the terminal prompt."
  logit "V$REL Supportconfig Conifugration Script complete."
  logit "-------------------------------------------------------------------"
  exit 1
fi

