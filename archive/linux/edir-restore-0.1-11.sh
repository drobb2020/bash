#!/bin/bash 
REL=0.01-11
##############################################################################
#
#    eDir-restore.sh - restore the local instance of eDirectory 8.8.x and all
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
# Date created: Fri Feb 25 09:00:00 2011
# Last updated: Tue Sep 17 14:52:57 2013 
# Crontab command: Not recommended
# Supporting file: /root/bin/eDirRestore.txt
# Additional notes: Don't forget to set the custom variables for your environment. 
##############################################################################
# Declare variables
HOST=$(hostname)
TODAY=$(date +"%d-%m-%Y")
CONF=/etc/opt/novell/eDirectory/conf
INCDIR=/root/bin
EMAIL=

# Extract the latest backup tarball
untar () {
cd /backup/$HOST/edir
tar zxvf $(ls | grep edirfilebackup) 
}

# Stop or Start ndsd and tomcat on server
ndsdstop () {
rcndsd stop 
}

ndsdstrt () {
rcndsd start 
}

tomcatrestrt () {
rcnovell-tomcat5 restart 
}

# Restore eDirectory configuration files
resedircfg () {
cp -f /backup/$HOST/edir/ndsbackup/edircfg/nds.conf $CONF/nds.conf
cp -f /backup/$HOST/edir/ndsbackup/edircfg/ndsimon.conf $CONF/ndsimon.conf
cp -f /backup/$HOST/edir/ndsbackup/edircfg/ndsmodules.conf $CONF/ndsmodules.conf
cp -f /backup/$HOST/edir/ndsbackup/edircfg/ndsd /etc/init.d/ndsd 
}

# Restore NICI configuration files
resnicicfg () {
cp -f /backup/$HOST/edir/ndsbackup/nicicfg/nici.cfg /etc/opt/novell/nici.cfg
cp -f /backup/$HOST/edir/ndsbackup/nicicfg/libccs2.so /opt/novell/lib/libccs2.so
cp -f /backup/$HOST/edir/ndsbackup/nicicfg/libccs2.so.2.7.6 /opt/novell/lib/libccs2.so.2.7.6 
}

# Restore nici files
resnici () {
cp -r -f /backup/$HOST/edir/ndsbackup/nici /var/opt/novell
chown -R wwwrun:www /var/opt/novell/nici/30 
}

# restore all eDirectory files
resedir () {
cp -r -f /backup/$HOST/edir/ndsbackup/eDirectory /var/opt/novell 
}

# Run the functions in the desired order
untar && ndsdstop && resedircfg && resnicicfg && resedir && resnici && ndsdstrt && tomcatrestrt

# Check ndsd status
/opt/novell/eDirectory/bin/ndsstat

# Send Report
mail -s "$HOST eDir Restore Report" $EMAIL <$INCDIR/edirrestore.txt

# Finished
exit
