#!/bin/bash
REL=0.1-11
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
# Date Created: August 10, 2010
# Last Updated: Thu Nov 01 09:56:21 2012 
# Company: Novell Inc.
# Crontab command: Not recommended
# Supporting file: /root/bin/eDirBackup.txt
# Additional notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare variables
HOST=$(hostname)
TODAY=$(date +"%d-%m-%Y")
CONF=/etc/opt/novell/eDirectory/conf
INCDIR=/root/bin

# Custom variables
EMAIL=edirreports@excs2net.org

# Stop and Start functions for eDirectory & Tomcat
ndsdstop () {
rcndsd stop 
}

ndsdstrt () {
rcndsd start 
}

tomcatrestrt () {
rcnovell-tomcat6 restart 
}

# Folder creation for backup
mkfldrs () {
cd /root
/bin/mkdir -p ndsBackup
cd ndsBackup
/bin/mkdir eDir-cfg
/bin/mkdir nici-cfg 
}

# Copy eDirectory configuration files
cpedircfg () {
/bin/cp $CONF/nds.conf /root/ndsBackup/eDir-cfg/nds.conf
/bin/cp $CONF/ndsimon.conf /root/ndsBackup/eDir-cfg/ndsimon.conf
/bin/cp $CONF/ndsmodules.conf /root/ndsBackup/eDir-cfg/ndsmodules.conf
/bin/cp /etc/init.d/ndsd /root/ndsBackup/eDir-cfg/ndsd 
}

# Copy NICI configuration files
cpnicicfg () {
/bin/cp /etc/opt/novell/nici.cfg /root/ndsBackup/nici-cfg/nici.cfg
/bin/cp /opt/novell/lib/libccs2.so /root/ndsBackup/nici-cfg/libccs2.so
/bin/cp /opt/novell/lib/libccs2.so.2.7.6 /root/ndsBackup/nici-cfg/libccs2.so.2.7.6 
}

# Copy all NICI files
cpnici () {
/bin/cp -r /var/opt/novell/nici /root/ndsBackup 
}

# Copy all eDirectory files
cpedir () {
/bin/cp -r /var/opt/novell/eDirectory /root/ndsBackup 
}

# Create tar archive
mktar () {
cd /root/
/bin/tar zcvf ndsbackup_$(date +'%Y%m%d').tar.gz /root/ndsBackup/*
/bin/rm -R ndsBackup 
}
# Pause the script
pause () { 
sleep 5
}

# Run the functions in the desired order
mkfldrs && ndsdstop && cpedircfg && cpnicicfg && cpedir && cpnici && pause && ndsdstrt && tomcatrestrt && mktar

# Check ndsd status
/opt/novell/eDirectory/bin/ndsstat -s

# Send Report
mail -s "$HOST eDir Backup Report" $EMAIL < $INCDIR/eDirBackup.txt

# Finished
exit

