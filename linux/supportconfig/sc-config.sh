#!/bin/bash
#===============================================================================
#
#          FILE: sc-config.sh
# 
#         USAGE: ./sc-config.sh 
# 
#   DESCRIPTION: Configure the server to collect a supportconfig 
#                on a daily basis
#
#                Copyright (c) 2020, David Robb
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
#       OPTIONS: suggested crontab command line:
#                0 2 * * * root /usr/local/bin/scripts/maintenance/sc-daily.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Thu Jun 19 2014 10:54
#  LAST UPDATED: Wed Sep 01 2021 13:20
#       VERSION: 0.1.16
#     SCRIPT ID: 010
#===============================================================================
USER=$(whoami)                                       # who is running the script
#===============================================================================
# USER Check - You must be root
if [ $EUID -ne "0" ]; then
  echo "You must be root to run this script, but you are: $USER."
  echo "The script will now exit. Please sudo to root and try again."
  exit 1
fi

# Create the supportconfig.conf file on the very first run
if [ -f /etc/supportconfig.conf ]; then
  echo "Configuration file already exists, continuing ..." > /dev/null
else
  /sbin/supportconfig -C
  # Customize supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_COMPANY=/s/"\([^"]*\)"/"Excession Systems"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_EMAIL=/s/"\([^"]*\)"/"david@excession.org"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_NAME=/s/"\([^"]*\)"/"David Robb"/g' /etc/supportconfig.conf
  sed -i '/VAR_OPTION_CONTACT_PHONE=/s/"\([^"]*\)"/"613-793-2281"/g' /etc/supportconfig.conf
fi

# Create a custom header file for SSC/RCMP
if [ -f /usr/lib/supportconfig/header.txt ]; then
  echo "The header.txt file already exists, continuing..." > /dev/null
else {
  echo -e "Excession Systems (EXCS)"
  echo -e "------------------------"
  echo -e "Security policy requires that all hostname and IP Addresses information"
  echo -e "be removed from any information provided to third-party vendors."
  echo -e "If this supportconfig collection needs to be provided to Micro Focus"
  echo -e "for additional analysis please contact the Micro Focus SSE and ask for"
  echo -e "a copy of the sc-clean.sh script."
  echo -e "This script will remove all occurrences of the hostname, and IP Address"
  echo -e "from all files in the supportconfig collection."
  echo -e "======================================================================="
} >> /usr/lib/supportconfig/header.txt

fi
# Create folder for holding the supportconfigs temporarily
if [ -d /home/sc_temp ]; then
  echo "sc_temp folder exists"
else
  install -m 755 -o excsadmin -g users -d /home/sc_temp
fi

# Create the daily crontab job for root
crontab -l > /tmp/sccron

if ! grep -q supportconfig /tmp/sccron; then
  echo "0 2 * * * /sbin/supportconfig -QR /home/sc_temp && /bin/chown excsadmin.users /home/sc_temp/nts*" >> /tmp/sccron
  crontab /tmp/sccron
  rm /tmp/sccron
else
  echo "crontab already configured"
fi

# Finished
exit 0
