#!/bin/bash - 
#===============================================================================
#
#          FILE: edir9-backup.sh
# 
#         USAGE: ./edir9-backup.sh 
# 
#   DESCRIPTION: Backup the local instance of eDirectory 9.1.x and all supporting files
#
#                Copyright (c) 2019, David Robb
#
#        GPL v2: This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License
#                as published by the Free Software Foundation; either version 2
#                of the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: 
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Wed Jan 09 2019 09:54
#   LAST UDATED: Wed Jan 09 2019 10:19
#       VERSION: 0.1.0
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.0                                    # version number of the script
sid=025                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=eDirectory-backup                          # email sender
email=root                                       # email recipient(s)
log='/var/log/edir-backup.log'                   # log name and location (if required)
ndsbin=/opt/novell/eDirectory/bin                # nds binary files
ndssbin=/opt/novell/eDirectory/sbin              # nds supervisor binary file
ndsconf=/etc/opt/novell/eDirectory/conf          # NDS configuration file location
now=$(date +'%Y%m%d_%H%M')                       # yearmonthday date_time stamp
#===============================================================================

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
ndsmanage stopall 
}

ndsdstrt () { 
echo "Starting ndsd after backup is complete"
ndsmanage startall
}

# Copy eDirectory configuration files
cpedircfg () {
echo "Backing up eDirectory configuration files..."
/bin/cp $ndsconf/nds.conf /tmp/ndsbackup/edircfg/nds.conf
/bin/cp $ndsconf/ndsimon.conf /tmp/ndsbackup/edircfg/ndsimon.conf
/bin/cp $ndsconf/ndsmodules.conf /tmp/ndsbackup/edircfg/ndsmodules.conf
/bin/cp $ndsconf/ndssnmp/edir.mib /tmp/ndsbackup/edircfg/edir.mib
/bin/cp $ndsconf/ndssnmp/ndssnmp.cfg* /tmp/ndsbackup/edircfg/
/bin/cp $ndsconf/ndssnmp/ndstrap.cfg* /tmp/ndsbackup/edircfg/
/bin/cp $ndsconf/env /tmp/ndsbackup/edirconf/env
# /bin/cp /etc/init.d/ndsd /tmp/ndsbackup/edircfg/ndsd 
}

# Backup NICI
cpnici () {
echo "Backing up NICI configuration files..."
tar -zcvf nici.tgz /var/opt/novell/nici/*
mv /var/opt/novell/nici/nici.tgz /tmp/ndsbackup/nicicfg/
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
ndsdstop && cpedircfg && cpedir && cpnici && pause && ndsdstrt

# Check ndsd status
/opt/novell/eDirectory/bin/ndsstat -s

# Tar up the files prior to sending the files to the archive server
mktar

# mail message
function mail_body1() { 
echo -e "An eDirectory file level backup has been performed on $host.\nThe backup tarball is located at /backup/$host/edir/$fn.\nThese files will assist in the recovery of the server if it becomes unresponsive or fails to restart and must be rebuilt.\nThank you,"
}

# Send backup Report
fn=$(ls /backup/$HOST/edir | grep $now)
mail_body1 | mail -s "$host eDirectory File level backup report" -a -r $mfrom $email

# Finished
exit 1

