#!/bin/bash - 
#===============================================================================
#
#          FILE: osbackup.sh
# 
#         USAGE: ./osbackup.sh 
# 
#   DESCRIPTION: Performs a backup of a server's /etc, /opt, /var, /home, and /root
#                directories
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
#       CREATED: Thu Aug 24 2017 11:02
#   LAST UDATED: Thu Mar 08 2018 09:45
#       VERSION: 0.1.2
#     SCRIPT ID: 065
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.2                                    # version number of the script
sid=065                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
dsp=$(date +'%A %B %d, %Y')                      # special date/time stamp
date=$(date +%Y%m%d%H%M)                         # date-time stamp
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=os-backup                                  # email sender
email=root                                       # email recipient(s)
log='/var/log/osbackup.log'                      # log name and location (if required)
bkdir=/global/data/osbackup                      # local backup destination
logdir=/var/log/osbackup/                        # tar logging directory
scdir=/global/data/sc_repo			                 # supportconfig directory
log=${logdir}/osbackup.log			                 # tar log file
errlog=${logdir}/osbackup.error.log		           # tar error log file
rep=$bkdir/osbackup_report-${host}-${date}.txt   # report name
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
  if [ -d ${bkdir} ]; then
    echo "backup directory exists, continuing" > /dev/null
  else
    mkdir -p $bkdir
  fi
}

mkscdir () { 
  if [ -d $scdir} ]; then
    echo -e "supportconfig directory exists, continuing" > /dev/null
  else
    mkdir -p $scdir
  fi
}

mklogdir
mkbkdir
mkscdir

# Space required
du -sB1 /etc >> /tmp/space_calc
du -sB1 /root >> /tmp/space_calc
du -sB1 /home >> /tmp/space_calc
du -sB1 /var >> /tmp/space_calc
du -sB1 /opt >> /tmp/space_calc

sc=$(cat /tmp/space_calc | cut -f 1 | paste -sd+ - | bc | numfmt --to=iec)

echo "------------------------------------------------------"
echo "Space Required for SUSE Manager backup"
echo "------------------------------------------------------"
echo "This backup will require $sc of space to complete."
echo "------------------------------------------------------"

# Generate a list of sockets for /opt and /var
find /opt -type s > /root/bin/opt_sockets.lst 2>/dev/null
find /var -type s > /root/bin/var_sockets.lst

echo -e "" | tee -a $rep
echo -e "======================================================" | tee -a $rep
echo -e "OS Backup Report" | tee -a $rep
echo -e "Host: $host" | tee -a $rep
echo -e "Date: $dsp" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep

# Backup /etc/, /opt/, /var/, /home, and /root on a regular schedule
echo -e "" | tee -a $rep
echo -e ">>> Begining backup of /etc/" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep
tar --ignore-failed-read -f ${bkdir}/etc_backup-${date}.tgz -cvz /etc/* > $log 2> $errlog
echo -e "\t >>> The backup of /etc/ has completed <<<"  | tee -a $rep

# Backup /home 
echo -e "" | tee -a $rep
echo -e ">>> Beginning backup of /home/" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep
tar --ignore-failed-read -f ${bkdir}/home_backup-${date}.tgz -cvz /home/* >> $log 2>> $errlog
echo -e "\t >>> The backup of /home/ is complete <<<" | tee -a $rep

# Backup of /opt
echo -e "" | tee -a $rep
echo -e ">>> Beginning backup of /opt/" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep
tar --ignore-failed-read -f ${bkdir}/opt_backup-${date}.tgz -cvz /opt/* --exclude=opt/novell/nss/mnt --exclude=opt/NAI --exclude=opt/scripts/os/isos --exclude-from=/root/bin/opt_sockets.lst >> $log 2>> $errlog
echo -e "\t>>> The backup of /opt/ is complete <<<" | tee -a $rep

# Backup of /root
echo -e "" | tee -a $rep
echo -e ">>> Beginning backup of /root/" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep
tar --ignore-failed-read -f ${bkdir}/root_backup-${date}.tgz -cvz /root/* --exclude=root/setup --exclude=root/shared --exclude=root/iso_images  --exclude=root/designer --exclude=root/designer_workspace >> $log 2>> $errlog
echo -e "\t>>> Backup of /root/ is complete <<<" | tee -a $rep

# Backup of /var
echo -e "" | tee -a $rep
echo -e ">>> Beginning backup of /var/" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep
tar --ignore-failed-read -f ${bkdir}/var_backup-${date}.tgz -cvz /var/* --exclude=var/opt/novell/eDirectory/data/dib --exclude=var/lib/ntp/proc --exclude=/var/spool --exclude=var/lib/named/proc --exclude=var/run --exclude=var/opt/novell/ganglia/rrds --exclude-from=/root/bin/var_sockets.lst >> $log 2>> $errlog
echo -e "\t >>> The backup of /var/ is complete <<<" | tee -a $rep

# Run a supportconfig to capture all information about the server
echo -e "" | tee -a $rep
echo -e ">>> Taking a supportconfig of the server" | tee -a $rep
echo -e "------------------------------------------------------" | tee -a $rep
/sbin/supportconfig -A -R ${scdir}
echo -e "\t>>> Supportconfig is complete <<<" | tee -a $rep

# Create a single tar ball of all the files in /global/data/osbackup
echo ">>> Creating a single archive file under ${bkupdir}" | tee -a $log
tar --ignore-failed-read -f ${bkupdir}/osbackup-${date}.tgz -cvz ${bkupdir}/etc_*.tgz ${bkupdir}/root_*.tgz ${bkupdir}/home_*.tgz ${bkupdir}/var_*.tgz ${bkupdir}/opt_*.tgz >> $log 2>> $errlog
echo -e "\t>>> A single tarball has been created for this backup operation <<<"
echo "------------------------------------------------------" | tee -a $rep

# Completion message
/usr/bin/clear
echo -e "" | tee -a $rep
echo -e "Operating System scheduled backup is complete" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
echo -e "The following tasks have been completed:" | tee -a $rep
echo -e "\t1) Backup of all files under /etc/, /opt/, /home, /root, and /var." | tee -a $rep
echo -e "\t2) A supportconfig of the server." | tee -a $rep
echo -e "" | tee -a $rep
echo -e "The backup tarballs have been added to a single tarball and can be found here: $bkdir/" | tee -a $rep
echo -e "The backup report can be found here: $rep" | tee -a $rep
echo -e "" | tee -a $rep

# Remove individual tarballs
echo -e "Cleaning up individual tarballs"
rm ${bkupdir}/etc*.tgz
rm ${bkupdir}/root*.tgz
rm ${bkupdir}/home*.tgz
rm ${bkupdir}/var*.tgz
rm ${bkupdir}/opt*.tgz
rm /tmp/space_calc
echo -e ""
echo -e "------------------------------------------------------"
echo -e "Backup of the operating system files is complete"
echo -e ""

# cleanup files
/bin/rm -f /root/bin/*.lst
/bin/rm -f $bkdir/*.md5
/bin/rm -f $bkdir/backup*.tbz
/bin/rm -f $bkdir/nts*.tbz
/bin/rm -f $bkdir/*.tar
/bin/rm -f $bkdir/*.log

# Finished
exit 1

