#!/bin/bash - 
#===============================================================================
#
#          FILE: edir-backup.sh
# 
#         USAGE: ./edir-backup.sh 
# 
#   DESCRIPTION: Backup the local instance of eDirectory 8.8.x and all supporting files
#
#                Copyright (c) 2018, David Robb
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
#       CREATED: Tue Aug 10 2010 09:00
#  LAST UPDATED: Mon Apr 15 2019 15:16
#       VERSION: 0.2.00
#     SCRIPT ID: 025
# SSC SCRIPT ID: 00
#===============================================================================
host=$(hostname)                                 # hostname of the local server
mfrom=eDirectory-backup                          # email sender
email=root                                       # email recipient(s)
ndsconf=/etc/opt/novell/eDirectory/conf          # NDS configuration file location
vardir=$(cat $ndsconf/nds.conf | grep n4u.server.vardir | cut -f 2 -d "=") # eDir var directory
dibdir=$(cat $ndsconf/nds.conf | grep n4u.nds.dibdir | cut -f 2 -d "=")    # eDir dib directory
logdir='/var/opt/novell/eDirectory/log'          # eDir log directory
now=$(date +'%Y%m%d_%H%M')                       # year-month-day date_time stamp
#===============================================================================

# Create temporary folders
if [ -d /tmp/ndsbackup ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /tmp/ndsbackup
  /bin/mkdir -p /tmp/ndsbackup/edircfg
  /bin/mkdir -p /tmp/ndsbackup/nicicfg
fi

# Press Enter function
press_enter() { 
  echo ""
  echo -n "Press Enter to continue"
  read -r
  clear
}

# Explanation of eDirectory backup
edirpurpose() { 
  echo -e "A file level backup of eDirectory is useful when you are upgrading"
  echo -e "or patching a configured server. This is a point in time backup, and"
  echo -e "an older backup should not be used to recover a server as it would"
  echo -e "negatively impact eDirectory replication."
  echo -e "This script will stop ndsd and backup both the dib set files and all"
  echo -e "eDir configuration files and logs."
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "+Please consult with the Micro Focus DSE before using this backup!+"
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

# Explanation of NICI backup
nicipurpose() { 
  echo -e "A file level backup of NICI is extremely useful in case the existing"
  echo -e "NICI files are accidentally lost. A backup of NICI is good for the "
  echo -e "life of the server and can be used at any time."
  echo -e "This script will backup both the NICI files and all NICI"
  echo -e "configuration files."
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo -e "+Please consult with the Micro Focus DSE before using this backup!+"
  echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

# Stop and Start functions for eDirectory & Tomcat
ndsdstop () {
echo ""
echo ">> Stopping ndsd in preparation for a file level backup"
/etc/init.d/ndsd stop 
}

ndsdstrt () {
echo "" 
echo ">> Starting ndsd after backup is complete"
/etc/init.d/ndsd start
}

# Backup eDirectory configuration files
cpedircfg () {
echo ""
echo ">> Backing up eDirectory configuration files..."
/usr/bin/rsync -av $ndsconf /tmp/ndsbackup/edircfg
# /bin/cp $ndsconf/nds.conf /tmp/ndsbackup/edircfg/nds.conf
# /bin/cp $ndsconf/ndsimon.conf /tmp/ndsbackup/edircfg/ndsimon.conf
# /bin/cp $ndsconf/ndsmodules.conf /tmp/ndsbackup/edircfg/ndsmodules.conf
/bin/cp /etc/init.d/ndsd /tmp/ndsbackup/edircfg/ndsd 
}

# Backup NICI configuration files
cpnicicfg () {
echo ""
echo ">> Backing up NICI configuration files..."
/bin/cp -av /etc/opt/novell/nici.cfg /tmp/ndsbackup/nicicfg/nici.cfg
/bin/cp -av /etc/opt/novell/nici64.cfg /tmp/ndsbackup/nicicfg/nici64.cfg
/bin/cp -av /opt/novell/lib/libccs2.so /tmp/ndsbackup/nicicfg/libccs2.so
/bin/cp -av /opt/novell/lib/libccs2.so.* /tmp/ndsbackup/nicicfg/ 
}

# Backup all NICI files
cpnici () {
echo ""
echo ">> Copying NICI files..."
/usr/bin/rsync -av /var/opt/novell/nici /tmp/ndsbackup 
}

# Backup all eDirectory files
cpedir () {
echo ""
echo ">> 4. Copying eDirectory files..."
/usr/bin/rsync -av "$vardir" /tmp/ndsbackup --exclude dib
/usr/bin/rsync -av "$logdir" /tmp/ndsbackup
/usr/bin/rsync -av "$dibdir" /tmp/ndsbackup
}

# Create tar archive
mktar1 () {
  cd /tmp || return
  /bin/mkdir -p /backup/"$host"/edir
  /bin/tar zcf /backup/"$host"/edir/edirnicifilebackup_"$host"_"$now".tgz ndsbackup/
  /bin/rm -Rf ndsbackup 
}

mktar2() { 
  cd /tmp || return
  /bin/mkdir -p /backup/"$host"/edir
  /bin/tar zcf /backup/"$host"/edir/edirfilebackup_"$host"_"$now".tgz ndsbackup/
  /bin/rm -Rf ndsbackup
}

mktar3() { 
  cd /tmp || return
  /bin/mkdir -p /backup/"$host"/nici
  /bin/tar zcf /backup/"$host"/nici/nicifilebackup_"$host"_"$now".tgz ndsbackup/
  /bin/rm -Rf ndsbackup
}

# Pause the script
pause () { 
  sleep 10
}

# Check ndsd status
edirstat() { 
  pause
  echo ""
  /opt/novell/eDirectory/bin/ndsstat -s
}

# mail message
mail_body1() { 
fn=$(grep "$now" /backup/"$host"/edir/)
echo -e "An eDirectory amd NICI file level backup has been performed on $host.\nThe backup tarball is located at /backup/$host/edir/$fn.\nThese files will assist in the recovery of the server if it becomes unresponsive or fails to restart and must be rebuilt.\nIf you want to use this backup to restore a server please consult with the Micro Focus DSE prior to using these files.\n\n  Thank you,"
}

mail_body2() { 
fn=$(grep "$now" /backup/"$host"/edir/)
echo -e "An eDirectory file level backup has been performed on $host.\nThe backup tarball is located at /backup/$host/edir/$fn.\nThese files can assist in the recovery of the server if it becomes unresponsive or fails to restart and must be rebuilt.\nIf you want to use this backup to restore a server please consult with the Micro Focus DSE prior to using these files.\n\n Thank you."
}
mail_body3() {
fn=$(grep "$now" /backup/"$host"/nici/) 
echo -e "A NICI file level backup has been performed on $host.\nThe backup tarball is located at /backup/$host/nici/$fn.\nThese files can be used to restore the correct NICI configuration on an OES server in case the NICI files are lost or damaged. These files are server specific and can only be used on this $host.\nIf you want to use this backup to restore a server please consult with the Micro Focus DSE prior to using these files.\n\n Thank you."
}

# Send backup Report
mailreport1() { 
  mail_body1 | mail -s "$host eDirectory & NICI file level backup report" -r $mfrom $email
}

mailreport2() { 
  mail_body2 | mail -s "$host eDirectory file level backup report" -r $mfrom $email
}

mailreport3() { 
  mail_body3 | mail -s "$host NICI file level backup report" -r $mfrom $email
}

# Selection Menu
selection=
until [ "$selection" = "0" ]; do
  clear
  echo ""
  echo "eDirectory & NICI Backup Script"
  echo "---------------------------------------------------"
  echo ""
  echo "Program Options"
  echo "1   -   Backup eDirectory DIB & eDirectory configuration files"
  echo "2   -   Backup NICI files & NICI configuration files"
  echo "3   -   Do a complete backup of eDirectory & NICI"
  echo ""
  echo "0   -   Exit Program"
  echo "---------------------------------------------------"
  read -r selection
  echo ""
  case $selection in
    1 ) edirpurpose ; ndsdstop ; cpedircfg ; cpedir ; ndsdstrt ; pause ; edirstat ; mktar2 ; mailreport2 ; press_enter ;;
    2 ) nicipurpose ; cpnicicfg ; cpnici ; mktar3 ; mailreport3 ; press_enter ;;
    3 ) edirpurpose ; nicipurpose ; ndsdstop ; cpedircfg ; cpnicicfg ; cpedir ; cpnici ; ndsdstrt ; pause ; edirstat ; mktar1 ; mailreport1 ; press_enter ;;
    0 ) exit ;;
    * ) echo "Please select 1,2, or 3. Press 0 to exit" ; press_enter 
  esac
done

# Finished
exit 0
