#!/bin/bash - 
#===============================================================================
#
#          FILE: edir-backup.sh
# 
#         USAGE: ./edir-backup.sh 
# 
#   DESCRIPTION: Backup the local instance of eDirectory 8.8.x and all supporting files
#
#                Copyright (C) 2016  David Robb
#
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: ---
#  REQUIREMENTS: /root/bin/eDirBackup.txt
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Aug 10 2010 09:00
#  LAST UPDATED: Sun Jun 19 2016 12:54
#      REVISION: 16
#     SCRIPT ID: 025
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.17
sid=025                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
now=$(date +'%Y%m%d_%H%M')                      # yearmonthday date_time stamp
ndsconf=/etc/opt/novell/eDirectory/conf         # NDS configuration file location
log='/var/log/edir-backup.log'                  # logging (if required)

# Create temporary folders
if [ -d /tmp/ndsbackup ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /tmp/ndsbackup
  /bin/mkdir -p /tmp/ndsbackup/edircfg
  /bin/mkdir -p /tmp/ndsbackup/nicicfg
fi

# Stop and Start functions for eDirectory & Tomcat
ndsdstop () {
echo "Stoping ndsd in preparation for backup"
/etc/init.d/ndsd stop 
}

ndsdstrt () { 
echo "Starting ndsd after backup is complete"
/etc/init.d/ndsd start
}

# Copy eDirectory configuration files
cpedircfg () {
echo "Backing up eDirectory configuration files..."
/bin/cp $ndsconf/nds.conf /tmp/ndsbackup/edircfg/nds.conf
/bin/cp $ndsconf/ndsimon.conf /tmp/ndsbackup/edircfg/ndsimon.conf
/bin/cp $ndsconf/ndsmodules.conf /tmp/ndsbackup/edircfg/ndsmodules.conf
/bin/cp /etc/init.d/ndsd /tmp/ndsbackup/edircfg/ndsd 
}

# Copy NICI configuration files
cpnicicfg () {
echo "Backing up NICI configuration files..."
/bin/cp /etc/opt/novell/nici.cfg /tmp/ndsbackup/nicicfg/nici.cfg
/bin/cp /etc/opt/novell/nici64.cfg /tmp/ndsbackup/nicicfg/nici64.cfg
/bin/cp /opt/novell/lib/libccs2.so /tmp/ndsbackup/nicicfg/libccs2.so
/bin/cp /opt/novell/lib/libccs2.so.2.7.7 /tmp/ndsbackup/nicicfg/libccs2.so.2.7.7 
}

# Copy all NICI files
cpnici () {
echo "Copying NICI files..."
/bin/cp -r /var/opt/novell/nici /tmp/ndsbackup 
}

# Copy all eDirectory files
cpedir () {
echo "Copying eDirectory files..."
/bin/cp -r /var/opt/novell/eDirectory /tmp/ndsbackup 
}

# Create tar archive
mktar () {
cd /tmp
/bin/mkdir -p /backup/$host/edir
/bin/tar zcf /backup/$host/edir/edirfilebackup_${host}_$(date +'%Y%m%d_%H%M').tgz ndsbackup/
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
FN=$(ls /backup/$HOST/edir | grep $now)
echo -e "An eDirectory file level backup has been performed on $host.\nThe backup tarball is located at /backup/$host/edir/$FN.\nThese files will assist in the recovery of the server if it becomes unresponsive or fails to restart and must be rebuilt.\nThank you," | mail -s "$host eDirectory File level backup report" $email

# Finished
exit 1

