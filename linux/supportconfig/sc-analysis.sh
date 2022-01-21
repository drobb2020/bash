#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-analysis.sh
# 
#         USAGE: ./sc-analysis.sh 
# 
#   DESCRIPTION: take a supportconfig of a server and upload it to the SCA Appliance
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
#       CREATED: Wed Dec 11 2013 08:26
#  LAST UPDATED: Sun Mar 18 2018 11:38
#       VERSION: 0.1.8
#     SCRIPT ID: 052
# SSC SCRIPT ID: 00
#===============================================================================
host=$(hostname)                                 # hostname of the local server
mfrom=supportconfig-analysis                     # email sender
email=root                                       # email recipient(s)

# Check to make sure you are root
if [ $EUID != root ]; then
  echo "You must be root to run this script."
  echo "The script will now exit, please sudo to root and try again."
  exit 1
fi

# Run supportconfig and upload it to the SCA
echo -e "Please standby as the supportconfig is collected and then uploaded to the SCA Appliance."
/sbin/supportconfig -QU 'ftp://acpic-s2800.ross.rossdev.rcmp-grc.gc.ca/upload'
echo -e "The supportconfig collection is complete and has been uploaded to the appliance."

# mail message
function mail_body1() { 
echo -e "You are on the list to be notified when a supportconfig has been run and sent to the Support Config Analysis (SCA) appliance. The analysis of the problem server should be ready in the next 5 minutes. If you are on the SCA Report e-mail list you will receive an e-mail copy of the report, otherwise please go to https://acpic-s2800.ross.rossdev.rcmp-grc.gc.ca, and login to view the report."
}

# email the list to let everyone know to expect a new analysis from the SCA Appliance
if [ -n "$email" ]; then
  mail_body1 | mail -s "A supportconfig for $host has been sent to the SCA Appliance" -r $mfrom $email
fi

# Finished
exit 0
