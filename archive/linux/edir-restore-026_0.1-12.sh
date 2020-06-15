#!/bin/bash
REL=0.1-12
SID=026
##############################################################################
#
#    eDir-restore.sh - restore the local instance of eDirectory 8.8.x and all
#                      supporting files from a previous backup
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
# Last updated: Wed Sep 18 15:02:15 2013 
# Crontab command: Not recommended
##############################################################################
# Declare variables
HOST=$(hostname)
TODAY=$(date +'%Y%m%d')
CONF=/etc/opt/novell/eDirectory/conf
NDSBIN=/opt/novell/eDirectory/bin
EMAIL=root

# Help screen to remind user of commandline syntax
function helpme() { 
	echo "--[ help ]-------------------------------------------------------"
	echo "The correct commandline syntax is:"
	echo "./edir-restore.sh YYYYMMDD"
	echo "for example ./edir-restore.sh 20130917"
	echo "================================================================="
	exit 1
}

# Issue a warning before the restore happens
function warning() { 
	echo "--[ Warning ]----------------------------------------------------"
	echo "This operation will replace all eDirectory files and related"
	echo "configuration files. This should only be done if you are"
	echo "restoring this server from a failed hardware or software upgrade."
	echo "================================================================="
}

# Stop nds daemon
function ndsdstop() { 
	/usr/sbin/rcndsd stop
}

# Start nds daemon
function ndsdstrt() { 
	/usr/sbin/rcndsd start
}

# Restore eDirectory configuration files
function resedircfg() { 
	/bin/cp -f /backup/$HOST/edir/ndsbackup/edircfg/nds.conf $CONF/nds.conf
	/bin/cp -f /backup/$HOST/edir/ndsbackup/edircfg/ndsimon.conf $CONF/ndsimon.conf
	/bin/cp -f /backup/$HOST/edir/ndsbackup/edircfg/ndsmodules.conf $CONF/ndsmodules.conf
	/bin/cp -f /backup/$HOST/edir/ndsbackup/edircfg/ndsd /etc/init.d/ndsd
}

# Restore NICI configuration files
function resnicicfg() { 
	/bin/cp -f /backup/$HOST/edir/ndsbackup/nicicfg/nici.cfg /etc/opt/novell/nici.cfg
	/bin/cp -f /backup/$HOST/edir/ndsbackup/nicicfg/libccs2.so /opt/novell/lib/libccs2.so
	/bin/cp -f /backup/$HOST/edir/ndsbackup/nicicfg/libccs2.so.2.7.6 /opt/novell/lib/libccs2.so.2.7.6
}

# Restore NICI files
function resnici() { 
	/bin/cp -f /backup/$HOST/edir/ndsbackup/nici /var/opt/novell
	/bin/chown -R wwwrun.www /var/opt/novell/nici/30
}

# Restore eDirectory files
function resedir() { 
	/bin/cp -f /backup/$HOST/edir/ndsbackup/eDirectory /var/opt/novell
}

# Untar the backup archive based on the date entered at the command line
if [ "$#" -lt 1 ]
    then
	echo "There are not enough arguments on the command line." > /dev/stderr
	helpme
    else
	cd /backup/$HOST/edir
	/bin/tar zxf $(ls | grep $1)
fi

# Do the restore if the user answers yes
warning
while true
    do
	read -p "Do you wish to continue with the restoration? (y/n) " YN
	echo "================================================================="
	case $YN in
	    [Yy]* ) ndsdstop && resedircfg && resnicicfg && resedir && resnici && ndsdstrt;;
	    [Nn]* ) exit 1;;
	    * ) echo "Please answer yes (y) or no (n).";;
	esac
    done

# Check ndsd status after the restore
$NDSBIN/ndsstat -s

# Send restore report
if [ -n $EMAIL ]
    then
	echo -e "An eDirectory restore has been performed on $HOST.\nIf you did not perform this restore, please investigate to find out who did, and document the reason.\nAll eDirectory and NICI files have been restored to their original versions and locations. This restore does not affect the binary version of the RPM packages for eDirectory or NICI.\n\nThank you." | mail -s "$HOST eDir Restore Report" $EMAIL
fi

# Finished
exit
