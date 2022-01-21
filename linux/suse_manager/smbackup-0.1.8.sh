#!/bin/bash - 
#===============================================================================
#
#          FILE: smbackup.sh
# 
#         USAGE: ./smbackup.sh 
# 
#   DESCRIPTION: Backup essential files for SUSE Manager 3.0/3.1
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
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Fri Mar 10 2017 11:29
#   LAST UDATED: Thu Oct 25 2018 17:15
#       VERSION: 0.1.8
#     SCRIPT ID: 082
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.8                                    # version number of the script
sid=082                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=suma-backup                                # email sender
email=root                                       # email recipient(s)
logdir='/var/log/smbackup'                       # location for log files
log='/var/log/smbackup/smbackup.log'             # logging (if required)
errlog='/var/log/smbackup/smbackup.error.log'    # error log location
bkupdir='/data/smbackup'                         # backup destination directory
date=$(date +%Y%m%d%H%M)                         # complete date-time stamp
etc_data='/etc/sysconfig/rhn/ /etc/rhn/ /etc/sudoers /etc/cobbler/ /etc/dhcpd.conf /etc/dhcp6.conf /etc/fstab' # files under /etc to backup
root_data='/root/.gnupg/ /root/ssl-build/ /root/.ssh/'                # files under /root to backup
srv_data='/srv/www/htdocs/pub/ /srv/tftpboot/ /srv/www/cobbler/'      # files under /srv to backup
var_data='/var/lib/cobbler/ /var/lib/rhn/kickstarts/'                 # files under /var to backup
spacewalk_data='/var/spacewalk/packages/ /var/spacewalk/db-backup/' # files under /var/spacewalk to backup
#===============================================================================

# Make any missing directories
mklogdir () { 
  if [ -d ${logdir} ]; then
    echo "logging directory exists, continuing" > /dev/null
  else
    mkdir -p $logdir
  fi
}

mkbkdir () { 
  if [ -d ${bkupdir} ]; then
    echo "backup directory exists, continuing" > /dev/null
  else
    mkdir -p $bkupdir
  fi
}

initlog() { 
if [ -d ${logdir} ]; then
  echo "Log directory exists, lets touch the log files" > /dev/null
  touch $logdir/smbackup.log
  echo "Logging started at ${ts}" > ${log}
  echo "All actions are being performed by the user: ${user}" >> ${log}
  echo " " >> ${log}
  touch $logdir/smbackup.error.log
  echo "Logging started at ${ts}" > ${errlog}
  echo "All actions are being performed by the user: ${user}" >> ${errlog}
  echo " " >> ${errlog}
fi
}

mklogdir
mkbkdir
initlog

# Welcome message
echo "---------------------------------------------------------------"
echo "SUSE Manager backup"
echo "---------------------------------------------------------------"
echo "Please standby, calculating the space required for this backup"
echo ""
# Space requiredi
du -sB1 /etc/sysconfig/rhn >> /tmp/space_calc
du -sB1 /etc/rhn >> /tmp/space_calc
du -sB1 /etc/cobbler >> /tmp/space_calc
du -sB1 /root/.gnupg >> /tmp/space_calc
du -sB1 /root/ssl-build >> /tmp/space_calc
du -sB1 /root/.ssh >> /tmp/space_calc
du -sB1 /srv/www/htdocs/pub >> /tmp/space_calc
du -sB1 /srv/tftpboot >> /tmp/space_calc
du -sB1 /srv/www/cobbler >> /tmp/space_calc
du -sB1 /var/lib/cobbler >> /tmp/space_calc
du -sB1 /var/lib/rhn/kickstarts >> /tmp/space_calc
du -sB1 /var/spacewalk/packages >> /tmp/space_calc
du -sB1 /var/spacewalk/db-backup >> /tmp/space_calc

sc=$(cat /tmp/space_calc | cut -f 1 | paste -sd+ - | bc | numfmt --to=iec)
su=$(df -h ${bkupdir} | awk 'END{ print $4 }')
scn=$(echo ${sc} | sed 's/[^0-9]//g') 
sun=$(df -h ${bkupdir} | awk 'END{ print $4 }' | sed 's/[^0-9]//g')

echo "Space Required for SUSE Manager backup"
echo "---------------------------------------------------------------"
echo "This backup will require $sc of uncompressed space to complete."
if [ $scn -ge $sun ]; then
  echo "You do not have sufficient storage space to perform a backup,"
  echo "script will now exit"
  # rm -f /tmp/space_calc
  exit 1
else
  echo "You have $su of free space, backup will now proceed"
  sleep 15
fi
echo "---------------------------------------------------------------"

# Create the etc backup tarball
echo ">>> Backing up critical files under /etc" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/etc_backup-${date}.tgz -cvz ${etc_data} > $log 2> $errlog
echo ""
echo -e "\t>>> Backup of /etc is complete <<<"
echo ""

# Create the root backup tarball
echo ">>> Backing up critical files under /root" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/root_backup-${date}.tgz -cvz ${root_data} >> $log 2>> $errlog
echo ""
echo -e "\t>>> Backup of /root is complete <<<"
echo ""

# Create the srv backup tarball
echo ">>> Backing up critical files under /srv" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/srv_backup-${date}.tgz -cvz ${srv_data} >> $log 2>> $errlog
echo ""
echo -e "\t>>> Backup of /srv is complete <<<"
echo ""

# Create the var backup tarball
echo ">>> Backing up critical files under /var/lib" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/var_backup-${date}.tgz -cvz ${var_data} >> $log 2>> $errlog
echo ""
echo -e "\t>>> Backup of /var/lib is complete <<<"
echo ""

# Create the spacewalk tarball
echo ">>> Backing up critical files under /var/spacewalk" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/spacewalk_backup-${date}.tgz -cvz ${spacewalk_data} >> $log 2>> $errlog
echo ""
echo -e "\t>>> Backup of /var/spacewalk is complete <<<"
echo ""

# Combine all files together into a single tarball
echo ">>> Creating a single archive file under ${bkupdir}" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/smbackup-${date}.tgz -cvz ${bkupdir}/etc_*.tgz ${bkupdir}/root_*.tgz ${bkupdir}/srv_*.tgz ${bkupdir}/var_*.tgz ${bkupdir}/spacewalk_*.tgz >> $log 2>> $errlog
echo ""
echo -e "\t>>> A single tarball has been created for this backup operation <<<"
echo "---------------------------------------------------------------"

# Remove individual tarballs
echo ">>> Cleaning up individual tarballs"
rm ${bkupdir}/etc*.tgz
rm ${bkupdir}/root*.tgz
rm ${bkupdir}/srv*.tgz
rm ${bkupdir}/var*.tgz
rm ${bkupdir}/spacewalk*.tgz
rm /tmp/space_calc

# Keep only the two newest backups
fcnt=$(ls $bkupdir | wc -l)
if [ $fcnt -ge 3 ]; then
  cd $bkupdir/
  (ls -t | head -n 2;ls) | sort | uniq -u | xargs rm
  cd ~/bin/
  echo ">>> Removing older SUSE Manager backups"
else
  echo ">>> There are less than 3 stored backups" > /dev/null
fi

# Space consummed by backups
echo "---------------------------------------------------------------"
sc2=$(ls -lh ${bkupdir} | awk 'NR == 1' | awk '{ print $2 }')
echo -e "The SUSE Manager backups are consumming $sc2 of"
echo -e "compressed space under $bkupdir."

# Completion message
echo "---------------------------------------------------------------"
echo -e "Backup of SUSE Manager critical files is complete"
echo -e "To see a list of files that were backed up, review the log:"
echo -e "$log"
echo -e "To see any errors during the backup, review the log:"
echo -e "$errlog"
echo -e "Remember to run this backup at regular intervals"
echo "---------------------------------------------------------------"
echo ""

exit 1

