#!/bin/bash 
REL=0.01-10
##############################################################################
#
#    eDir-restore88x.sh - restore the local instance of eDirectory 8.8.x and all
#                         supporting files from a previous backup
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
# Date created: February 25, 2011
# Last updated: Mon Apr 16 13:37:43 2012 
# Crontab command: Not recommended
# Supporting file: /root/bin/eDirRestore.txt
# Additional notes: Don't forget to set the custom variables for your environment. 
##############################################################################
# Declare variables
HOST=$(hostname)
TODAY=$(date +"%d-%m-%Y")
CONF=/etc/opt/novell/eDirectory/conf
INCDIR=/root/bin

# Custom variables
EMAIL=

# Extract the latest backup tarball
untar () {
cd /root
tar zxvf $(ls | grep ndsbackup) 
}

# Stop or Start ndsd and tomcat on server
ndsdstop () {
rcndsd stop 
}

ndsdstrt () {
rcndsd start 
}

tomcatrestrt () {
rcnovell-tomcat6 restart 
}

# Restore eDirectory configuration files
resedircfg () {
cp -f /root/ndsBackup/eDir-cfg/nds.conf $CONF/nds.conf
cp -f /root/ndsBackup/eDir-cfg/ndsimon.conf $CONF/ndsimon.conf
cp -f /root/ndsBackup/eDir-cfg/ndsmodules.conf $CONF/ndsmodules.conf
cp -f /root/ndsBackup/eDir-cfg/ndsd /etc/init.d/ndsd 
}

# Restore NICI configuration files
resnicicfg () {
cp -f /root/ndsBackup/nici-cfg/nici.cfg /etc/opt/novell/nici.cfg
cp -f /root/ndsBackup/nici-cfg/libccs2.so /opt/novell/lib/libccs2.so
cp -f /root/ndsBackup/nici-cfg/libccs2.so.2.7.6 /opt/novell/lib/libccs2.so.2.7.6 
}

# Restore nici files
resnici () {
cp -r -f /root/ndsBackup/nici /var/opt/novell
chown -R wwwrun:www /var/opt/novell/nici/30 
}

# restore all eDirectory files
resedir () {
cp -r -f /root/ndsBackup/eDirectory /var/opt/novell 
}

# Run the functions in the desired order
untar && ndsdstop && resedircfg && resnicicfg && resedir && resnici && ndsdstrt && tomcatrestrt

# Check ndsd status
/opt/novell/eDirectory/bin/ndsstat

# Send Report
mail -s "$HOST eDir Restore Report" $EMAIL <$INCDIR/eDirRestore.txt

# Finished
exit

