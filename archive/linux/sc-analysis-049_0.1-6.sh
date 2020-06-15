#!/bin/bash
REL=0.1-6
SID=049
ID=8
##############################################################################
#
#    sc-analysis.sh - Script is used to take a supportconfig of a 
#                     server and upload it to the SCA Appliance
#    Copyright (C) 2013  David Robb
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
#       Jacques Guillemette (jacques.guillemette@ssc-spc.gc.ca)
#
##############################################################################
# Date Created: Wed Dec 11 08:26:17 2013 
# Last updated: Thu May 28 08:18:34 2015 
# Crontab command: Not recommended - run only as directed by your xSE
# Supporting file: None
# Additional notes: 
##############################################################################
HOST=$(hostname)
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root


# Run supportconfig and upload it to the SCA
echo -e "Please standby as the supportconfig is collected."
/sbin/supportconfig -QU 'ftp://acpic-s2800.ross.rossdev.rcmp-grc.gc.ca/upload'
echo -e "The supportconfig collection is complete and has been uploaded to the appliance."

# email the list to let everyone know to expect a new analysis from the SCA Appliance
if [ -n $EMAIL ]; then
  echo -e "You are on the list to be notified when a supportconfig has been run and sent to the Support Config Analysys (SCA) appliance. The analysis of the problem server should be ready in the next 5 minutes. If you are on the SCA Report e-mail list you will receive an e-mail copy of the report, otherwise please go to https://acpic-s2800.ross.rossdev.rcmp-grc.gc.ca, and login to view the report." | mail -s "A supportconfig for $HOST has been sent to the SCA Appliance" $EMAIL
fi

# Finished
exit 1

