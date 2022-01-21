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
#  LAST UPDATED: Thu Sep 17 2020 13:11
#       VERSION: 0.1.3
#     SCRIPT ID: 065
# SSC SCRIPT ID: 00
#===============================================================================
dsp=$(date +'%A %B %d, %Y')                      # special date/time stamp
date=$(date +%Y%m%d%H%M)                         # date-time stamp
host=$(hostname)                                 # hostname of the local server
log='/var/log/osbackup.log'                      # log name and location (if required)
bkdir=/global/data/osbackup                      # local backup destination
logdir=/var/log/osbackup/                        # tar logging directory
scdir=/global/data/sc_repo		                   # supportconfig directory
log=${logdir}/osbackup.log		                   # tar log file
errlog=${logdir}/osbackup.error.log	             # tar error log file
rep=$bkdir/osbackup_report-${host}-${date}.txt   # report name
#===============================================================================
# Make any missing directories
mklogdir () { 
  if [ -d "$logdir" ]; then
    echo "log directory exists, continuing" > /dev/null
  else
    mkdir -p "$logdir"
  fi
}

mkbkdir () { 
  if [ -d "$bkdir" ]; then
    echo "backup directory exists, continuing" > /dev/null
  else
    mkdir -p "$bkdir"
  fi
}

mkscdir () { 
  if [ -d "$scdir" ]; then
    echo -e "supportconfig directory exists, continuing" > /dev/null
  else
    mkdir -p "$scdir"
  fi
}

mklogdir
mkbkdir
mkscdir

# Generate a list of sockets for /opt and /var
find /opt -type s > /root/bin/opt_sockets.lst 2>/dev/null
find /var -type s > /root/bin/var_sockets.lst

echo -e "" | tee -a "$rep"
echo -e "======================================================" | tee -a "$rep"
echo -e "OS Backup Report" | tee -a "$rep"
echo -e "Host: $host" | tee -a "$rep"
echo -e "Date: $dsp" | tee -a "$rep"
echo -e "------------------------------------------------------" | tee -a "$rep"

# Backup /etc
echo -e "" | tee -a "$rep"
echo -e "Beginning backup of /etc" | tee -a "$rep"
echo -e "------------------------------------------------------" | tee -a "$rep"
tar --ignore-failed-read -f ${bkdir}/etc_backup-"$date".tgz -cvz /etc/* > $log 2> $errlog
echo -e "\t >>> The backup of /etc/ has completed <<<"  | tee -a "$rep"

# Backup /home 
echo -e "" | tee -a "$rep"
echo -e "Beginning backup of /home" | tee -a "$rep"
echo -e "------------------------------------------------------" | tee -a "$rep"
tar --ignore-failed-read -f ${bkdir}/home_backup-"$date".tgz -cvz /home/* >> $log 2>> $errlog
echo -e "\t >>> The backup of /home/ is complete <<<" | tee -a "$rep"

# Backup of /opt
echo -e "" | tee -a "$rep"
echo -e "Beginning backup of /opt" | tee -a "$rep"
echo -e "------------------------------------------------------" | tee -a "$rep"
tar --ignore-failed-read -f ${bkdir}/opt_backup-"$date".tgz -cvz /opt/* --exclude=opt/novell/nss/mnt --exclude=opt/NAI --exclude=opt/scripts/os/isos --exclude-from=/root/bin/opt_sockets.lst >> $log 2>> $errlog
echo -e "\t>>> The backup of /opt/ is complete <<<" | tee -a "$rep"

# Backup of /root
echo -e "" | tee -a "$rep"
echo -e "Beginning backup of /root" | tee -a "$rep"
echo -e "------------------------------------------------------" | tee -a "$rep"
tar --ignore-failed-read -f ${bkdir}/root_backup-"$date".tgz -cvz /root/* --exclude=root/setup --exclude=root/shared --exclude=root/iso_images  --exclude=root/designer --exclude=root/designer_workspace >> $log 2>> $errlog
echo -e "\t>>> Backup of /root/ is complete <<<" | tee -a "$rep"

# Backup of /var
echo -e "" | tee -a "$rep"
echo -e "Beginning backup of /var" | tee -a "$rep"
echo -e "------------------------------------------------------" | tee -a "$rep"
tar --ignore-failed-read -f ${bkdir}/var_backup-"$date".tgz -cvz /var/* --exclude=var/opt/novell/eDirectory/data/dib --exclude=var/lib/ntp/proc --exclude=/var/spool --exclude=var/lib/named/proc --exclude=var/run --exclude=var/opt/novell/ganglia/rrds --exclude-from=/root/bin/var_sockets.lst >> $log 2>> $errlog
echo -e "\t >>> The backup of /var/ is complete <<<" | tee -a "$rep"

# Determine installed OS version (SLES or RedHat)
if [ -e /etc/os-release ]; then
  os=$(grep -w "NAME" /etc/os-release | cut -f 2 -d '=' | sed 's/"//g')
else
  os=RedHat
fi

# Run a supportconfig or sos report to capture all information about the server
if [ $os = SLES ]; then
  echo -e "" | tee -a "$rep"
  echo -e ">>> Taking a supportconfig of the server" | tee -a "$rep"
  echo -e "------------------------------------------------------" | tee -a "$rep"
  /sbin/supportconfig -A -R ${scdir}
  echo -e "\t>>> Supportconfig is complete <<<" | tee -a "$rep"
else
  echo -e "" | tee -a "$rep"
  echo -e ">>> Taking a SOS Report of the server" | tee -a "$rep"
  echo -e "------------------------------------------------------" | tee -a "$rep"
  /usr/sbin/sosreport -a --batch --name "$host" --tmp-dir "$scdir"
  echo -e "\t>>> SOS Report is complete <<<" | tee -a "$rep"
fi

# Create a single tar ball of all the files in /global/data/osbackup
echo ">>> Creating a single archive file under ${bkdir}" | tee -a "$log"
tar --ignore-failed-read -f ${bkdir}/osbackup-"$date".tgz -cvz ${bkdir}/etc_*.tgz ${bkdir}/root_*.tgz ${bkdir}/home_*.tgz ${bkdir}/var_*.tgz ${bkdir}/opt_*.tgz >> "$log" 2>> "$errlog"
echo -e "\t>>> A single tarball has been created for this backup operation <<<"
echo "------------------------------------------------------" | tee -a "$rep"

# Completion message
/usr/bin/clear
echo -e "" | tee -a "$rep"
echo -e "Operating System backup is complete" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
echo -e "The following tasks have been completed:" | tee -a "$rep"
echo -e "\t1) Backup of all files under /etc/, /opt/, /home, /root, and /var." | tee -a "$rep"
echo -e "\t2) A supportconfig or SOS Report of the server." | tee -a "$rep"
echo -e "" | tee -a "$rep"
echo -e "The backup tarballs have been added to a single tarball and can be found here: $bkdir/" | tee -a "$rep"
echo -e "The backup report can be found here: $rep" | tee -a "$rep"
echo -e "Before the server is upgraded the backup should be moved to a safe location." | tee -a "$rep"
echo -e "" | tee -a "$rep"

# Remove individual tarballs
rm -rf ${bkdir}/etc*.tgz
rm -rf ${bkdir}/root*.tgz
rm -rf ${bkdir}/home*.tgz
rm -rf ${bkdir}/var*.tgz
rm -rf ${bkdir}/opt*.tgz
rm -rf /tmp/space_calc
# cleanup miscellaneous files
/bin/rm -f /root/bin/*.lst
/bin/rm -f /root/bin/*.gz
/bin/rm -f $bkdir/*.md5
/bin/rm -f $bkdir/backup*.tbz
/bin/rm -f $bkdir/nts*.tbz
/bin/rm -f $bkdir/*.tar
/bin/rm -f $bkdir/*.log

echo -e ""
echo -e "------------------------------------------------"
echo -e "Backup of the operating system files is complete"
echo -e ""

# Finished
exit 0
