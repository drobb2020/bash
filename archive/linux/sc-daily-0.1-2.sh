#!/bin/bash
REL=0.1-02
##############################################################################
#
#    daily-sc.sh - Create a daily supportconfig and e-mail the basic-health-
#                  report.txt to any desired user.
#    Copyright (C) 2012  David Robb
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
# Date Created: Tue Oct 02 14:30:07 2012
# Last updated: Wed Jan 23 14:01:00 2013
# Suggested Crontab command: 30 1 * * * /root/bin/daily-sc.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DOWS=$(date +%a)
DOWF=$(date +%A)
HOST=$(hostname)
EMAIL=root

# Create Directory structure if it doesn't exist
if [ -d /backup/supportconfig/$DOWS ]
    then
	echo "Directory exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /backup/supportconfig/$DOWS
fi

# Remove any old supportconfig
if [ -d /backup/supportconfig/$DOWS ]
    then
	/bin/rm -r /backup/supportconfig/$DOWS/* 1>2 /dev/null
fi

# Run supportconfig quietly
/sbin/supportconfig -QR /backup/supportconfig/$DOWS

# Get the full name of the supportconfig
FN=$(ls /backup/supportconfig/$DOWS | grep tbz | cut -f 1 -d "." | head -n 1)

# Extract only the basic-health-report file
pushd .
cd /backup/supportconfig/$DOWS
tar -jxf $FN.tbz $FN/basic-health-report.txt
popd

# E-mail the report
if [ -n $EMAIL ]
    then
	mail -s "Basic Health Report for $HOST" $EMAIL < /backup/supportconfig/$DOWS/$FN/basic-health-report.txt
fi

#Finished
exit

