#!/bin/bash
REL=0.1-2
SID=022
##############################################################################
#
#    dsbkprep.sh - Backup the DIB set and NICI on an OES server
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
# Date Created: Mon Sep 16 09:00:45 2013 
# Last updated: Wed May 27 13:05:31 2015 
# Suggested Crontab command: 00 3 * * * /root/bin/dib-backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Create dsbk.conf
if [ -f /tmp/dsbk.tmp ]; then
  echo "DSBK has been configured, continuing ..." >> /dev/null
else
  touch /tmp/dsbk.tmp
  echo "/tmp/dsbk.tmp" > /etc/dsbk.conf
fi

# Configure rfl for dsbk
if [ -d /var/rfl ]; then
  echo "RFL has been configured, continuing ..." >> /dev/null
else
  mkdir -p /var/rfl
  dsbk setconfig -L -r /var/rfl
  sleep 30
fi

exit 1

