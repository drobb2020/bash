#!/bin/bash
#===============================================================================
#
#          FILE: smbackup.sh
#
#         USAGE: ./smbackup.sh
#
#   DESCRIPTION: Backup essential files for SUSE Manager 3.0
#
#                Copyright (C) 2017  David Robb
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS:
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: Fri Mar 10 2017 11:29
#  LAST UPDATED: Sun Mar 12 2017 09:38
#       VERSION: 1.2
#     SCRIPT ID: ---
# SSC UNIQUE ID: --
#===============================================================================
bkupdir='/global/data/smbackup'
logdir='/var/log/smbackup'
log=${logdir}/smbackup.log
errlog=${logdir}/smbackup.error.log
date=$(date +%Y%m%d%H%M)
etc_data='/etc/sysconfig/rhn/ /etc/rhn/ /etc/sudoers /etc/cobbler/ /etc/dhcp.conf'
root_data='/root/.gnupg/ /root/ssl-build/ /root/.ssh/'
srv_data='/srv/www/htdocs/pub/ /srv/tftpboot/ /srv/www/cobbler/'
var_data='/var/lib/cobbler/ /var/lib/rhn/kickstarts'
spacewalk_data='/var/spacewalk/packages/1/'

# Make any missing directories
mklogdir () { 
  if [ -d ${logdir} ]; then
    echo "logging directory exists, continuing" > /dev/null
  else
    mkdir -p /var/log/smbackup
  fi
}

mkbkdir () { 
  if [ -d ${bkupdir} ]; then
    echo "backup directory exists, continuing" > /dev/null
  else
    mkdir -p /global/data/smbackup
  fi
}

mklogdir
mkbkdir

# Space required
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
du -sB1 /var/spacewalk/packages/1 >> /tmp/space_calc
sc=$(cat /tmp/space_calc | cut -f 1 | paste -sd+ - | bc | numfmt --to=iec)

echo "------------------------------------------------------"
echo "Space Required for backup"
echo "------------------------------------------------------"
echo "This backup will require $sc of space to complete."
echo "------------------------------------------------------"

sleep 20

# Create the etc backup tarball
echo ">>> Backing up critical files under /etc" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/etc_backup-${date}.tgz -cvz ${etc_data} > $log 2> $errlog

# Create the root backup tarball
echo ">>> Backing up critical files under /root" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/root_backup-${date}.tgz -cvz ${root_data} >> $log 2>> $errlog

# Create the srv backup tarball
echo ">>> Backing up critical files under /srv" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/srv_backup-${date}.tgz -cvz ${srv_data} >> $log 2>> $errlog

# Create the var backup tarball
echo ">>> Backing up critical files under /var" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/var_backup-${date}.tgz -cvz ${var_data} >> $log 2>> $errlog

# Create the spacewalk tarball
echo ">>> Backing up critical files under /var/spacewalk" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/spacewalk_backup-${date}.tgz -cvz ${spacewalk_data} >> $log 2>> $errlog

# Combine all files together into a single tarball
echo ">>> Creating a single archive file under ${bkupdir}" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/smbackup-${date}.tgz -cvz ${bkupdir}/etc_*.tgz ${bkupdir}/root_*.tgz ${bkupdir}/srv_*.tgz ${bkupdir}/var_*.tgz ${bkupdir}/spacewalk_*.tgz >> $log 2>> $errlog
echo "------------------------------------------------------"

# Remove individual tarballs
echo "Cleaning up"
rm ${bkupdir}/etc*.tgz
rm ${bkupdir}/root*.tgz
rm ${bkupdir}/srv*.tgz
rm ${bkupdir}/var*.tgz
rm ${bkupdir}/spacewalk*.tgz
rm /tmp/space_calc

exit 1

