#!/bin/bash
REL=0.1-12
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
# Last Updated: Fri Jun 28 15:48:10 2013 
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
EMAIL=root

# Stop and Start functions for eDirectory & Tomcat
ndsdstop () {
rcndsd stop 
}

ndsdstrt () {
rcndsd start 
}

tomcatrestrt () {
TC5=$(ps -ef | grep -v grep | grep -cw tomcat5)
TC6=$(ps -ef | grep -v grep | grep -cw tomcat6)
	if [ $TC5 -ge 1 ]
		then
			rcnovell-tomcat5 restart 
	fi
	if [ $TC6 -ge 1 ]
		then
			rcnovell-tomcat6 restart
	fi
}

# Folder creation for backup
mkfldrs () {
cd /
/bin/mkdir -p /backup/ndsBackup
cd /backup/ndsBackup
/bin/mkdir eDir-cfg
/bin/mkdir nici-cfg 
}

# Copy eDirectory configuration files
cpedircfg () {
/bin/cp $CONF/nds.conf /backup/ndsBackup/eDir-cfg/nds.conf
/bin/cp $CONF/ndsimon.conf /backup/ndsBackup/eDir-cfg/ndsimon.conf
/bin/cp $CONF/ndsmodules.conf /backup/ndsBackup/eDir-cfg/ndsmodules.conf
/bin/cp /etc/init.d/ndsd /backup/ndsBackup/eDir-cfg/ndsd 
}

# Copy NICI configuration files
cpnicicfg () {
/bin/cp /etc/opt/novell/nici.cfg /backup/ndsBackup/nici-cfg/nici.cfg
/bin/cp /opt/novell/lib/libccs2.so /backup/ndsBackup/nici-cfg/libccs2.so
/bin/cp /opt/novell/lib/libccs2.so.2.7.6 /backup/ndsBackup/nici-cfg/libccs2.so.2.7.6 
}

# Copy all NICI files
cpnici () {
/bin/cp -r /var/opt/novell/nici /backup/ndsBackup 
}

# Copy all eDirectory files
cpedir () {
/bin/cp -r /var/opt/novell/eDirectory /backup/ndsBackup 
}

# Create tar archive
mktar () {
cd /backup/
/bin/tar zcf edirfilebackup_$(hostname)_$(date +'%Y%m%d').tgz ndsBackup/
/bin/rm -R ndsBackup 
}

# Pause the script
pause () { 
sleep 5
}

# Run the functions in the desired order
mkfldrs && ndsdstop && cpedircfg && cpnicicfg && cpedir && cpnici && pause && ndsdstrt && tomcatrestrt

# Check ndsd status
/opt/novell/eDirectory/bin/ndsstat -s

# Tar up the files prior to sending the files to the archive server
mktar

# rsync the tar ball to the archive server
rsync -a -v -e "ssh -l root" /backup/edirfilebackup*.tgz d4:/backup/ndsbackup/

# Delete local archive file
/bin/rm -f edirfilebackup*.tgz

# Send Report
mail -s "$HOST eDirectory File level backup report" $EMAIL < $INCDIR/edirbackup.txt

# Finished
exit
