#!/bin/bash
REL=0.1-14
##############################################################################
#
#    edir-backup88x.sh - backup the local instance of eDirectory 8.8.x and all
#                        supporting files
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
# Date Created: Tue Aug 10 09:00:00 2010
# Last Updated: Mon May 11 08:04:41 2015 
# Company: Novell Inc.
# Crontab command: Not recommended
# Supporting file: /root/bin/eDirBackup.txt
# Additional notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare variables
HOST=$(hostname)
TODAY=$(date +'%Y%m%d')
CONF=/etc/opt/novell/eDirectory/conf
EMAIL=root

# Create temporary folders
if [ -d /tmp/ndsbackup ]
    then
	echo "Directory exists, continuing ..." >> /dev/null
    else
	/bin/mkdir -p /tmp/ndsbackup
	/bin/mkdir -p /tmp/ndsbackup/edircfg
	/bin/mkdir -p /tmp/ndsbackup/nicicfg
fi

# Stop and Start functions for eDirectory & Tomcat
ndsdstop () {
rcndsd stop 
}

ndsdstrt () {
rcndsd start 
}

# Copy eDirectory configuration files
cpedircfg () {
/bin/cp $CONF/nds.conf /tmp/ndsbackup/edircfg/nds.conf
/bin/cp $CONF/ndsimon.conf /tmp/ndsbackup/edircfg/ndsimon.conf
/bin/cp $CONF/ndsmodules.conf /tmp/ndsbackup/edircfg/ndsmodules.conf
/bin/cp /etc/init.d/ndsd /tmp/ndsbackup/edircfg/ndsd 
}

# Copy NICI configuration files
cpnicicfg () {
/bin/cp /etc/opt/novell/nici.cfg /tmp/ndsbackup/nicicfg/nici.cfg
/bin/cp /opt/novell/lib/libccs2.so /tmp/ndsbackup/nicicfg/libccs2.so
/bin/cp /opt/novell/lib/libccs2.so.2.7.7 /tmp/ndsbackup/nicicfg/libccs2.so.2.7.7 
}

# Copy all NICI files
cpnici () {
/bin/cp -r /var/opt/novell/nici /tmp/ndsbackup 
}

# Copy all eDirectory files
cpedir () {
/bin/cp -r /var/opt/novell/eDirectory /tmp/ndsbackup 
}

# Create tar archive
mktar () {
cd /tmp
/bin/mkdir -p /backup/$HOST/edir
/bin/tar zcf /backup/$HOST/edir/edirfilebackup_$(hostname)_$(date +'%Y%m%d').tgz ndsbackup/
/bin/rm -Rf ndsbackup 
}

# Pause the script
pause () { 
sleep 5
}

# Run the functions in the desired order
ndsdstop && cpedircfg && cpnicicfg && cpedir && cpnici && pause && ndsdstrt

# Check ndsd status
/opt/novell/eDirectory/bin/ndsstat -s

# Tar up the files prior to sending the files to the archive server
mktar

# Send backup Report
FN=$(ls /backup/$HOST/edir | grep $TODAY)
echo -e "An eDirectory file level backup has been performed on $HOST.\nThe backup tarball is located at /backup/$HOST/edir/$FN.\nThese files will assist in the recovery of the server if it becomes unresponsive or fails to restart and must be rebuilt.\nThank you," | mail -s "$HOST eDirectory File level backup report" $EMAIL

# Finished
exit

