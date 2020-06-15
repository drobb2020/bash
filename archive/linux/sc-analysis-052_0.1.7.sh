#!/bin/bash - 
#===============================================================================
#
#          FILE: sc-analysis.sh
# 
#         USAGE: ./sc-analysis.sh 
# 
#   DESCRIPTION: Script is used to take a supportconfig of a server and upload it to the SCA Appliance
#
#                Copyright (C) 2015  David Robb
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
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Wed Dec 11 2013 08:26
#  LAST UPDATED: Wed Jul 22 2015 11:30
#      REVISION: 7
#     SCRIPT ID: 052
# SSC SCRIPT ID: ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.7
sid=052                                     # personal script id number
uid=00                                      # SSC/RCMP script id number
ts=$(date +"%b %d %T")                      # general date/time stamp
ds=$(date +%a)                              # breviated day of the week, eg Mon
df=$(date +%A)                              # full day of the week, eg Monday
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/sc-analysis.log'              # logging (if required)

# Check to make sure you are root
if [ $user != root ]; then
  echo "You must be root to run this script."
  echo "The script will now exit, please sudo to root and try again."
  exit 1
fi

# Run supportconfig and upload it to the SCA
echo -e "Please standby as the supportconfig is collected and then uploaded to the SCA Appliance."
/sbin/supportconfig -QU 'ftp://acpic-s2800.ross.rossdev.rcmp-grc.gc.ca/upload'
echo -e "The supportconfig collection is complete and has been uploaded to the appliance."

# email the list to let everyone know to expect a new analysis from the SCA Appliance
if [ -n $email ]; then
  echo -e "You are on the list to be notified when a supportconfig has been run and sent to the Support Config Analysys (SCA) appliance. The analysis of the problem server should be ready in the next 5 minutes. If you are on the SCA Report e-mail list you will receive an e-mail copy of the report, otherwise please go to https://acpic-s2800.ross.rossdev.rcmp-grc.gc.ca, and login to view the report." | mail -s "A supportconfig for $host has been sent to the SCA Appliance" $email
fi

# Finished
exit 1

