#!/bin/bash
REL=0.1-1
SID=025
##############################################################################
#
#    edirhealth.sh - script to check nds health on the local server.
#    Copyright (C) 2013  David Robb
#
##############################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
# Date Created: Wed Oct 02 13:04:55 2013 
# Last updated: Wed May 27 13:15:30 2015 
# Crontab command: 
# Supporting file: None
# Additional notes: 
##############################################################################
# Declare variables
DS=$(date +%a)
DF=$(date +%A)
TS=$(date +'%b %d %T')
HOST=$(hostname)
NDSBIN=/opt/novell/eDirectory/bin
NDSCONF=/etc/opt/novell/eDirectory/conf/nds.conf
FN=$HOST$DF
ADM=admin.rnd
EMAIL=root

# Create folder to store report
if [ -d /backup/$HOST/health ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$HOST/health
fi

# Run ndscheck
$NDSBIN/ndscheck -a $ADM -F /backup/$HOST/health/$FN -W -q --config-file $NDSCONF

# E-mail the results
if [ -n "$EMAIL" ]; then
  mail -s "eDirectory Health Check for $HOST" $EMAIL < /backup/$HOST/health/$FN
fi

# Finished
exit 1

