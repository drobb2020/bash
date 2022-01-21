#!/bin/bash - 
#===============================================================================
#
#          FILE: preupchk.sh
# 
#         USAGE: ./preupchk.sh 
# 
#   DESCRIPTION: Performs the required OES2018 pre-upgrade backups of /etc, /opt,
#                /var, /home, and /root as suggested in the OES2018 Installation
#                Guide
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
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Jan 26 2016 08:41
#  LAST UPDATED: Mon Jun 04 2018 09:49
#      REVISION: 9
#     SCRIPT ID: 065
# SSC UNIQUE ID: 28
#===============================================================================
dsp=$(date +'%A %B %d, %Y')                     # special date/time stamp
date=$(date +%Y%m%d%H%M)                        # date-time stamp
host=$(hostname)                                # host name of local server
lip=$(hostname -i)                              # local IP Address
fqdn=$(hostname -f)                             # fully qualified domain hostname

osver=$(grep PRETTY /etc/os-release | cut -f 2 -d "=" | awk '{print $1,$2,$3,$4,$5,$6}' | sed 's/"//g') # installed OS version
oesver=$(grep Novell /etc/novell-release) # installed OES version
log='/var/log/preupbk.log'                      # logging (if required)
errlog='/var/log//preupbk.error.log'            # tar error log file
bkdir=/home/backup      	                # local backup destination
rep=$bkdir/OES2018_backup_report-$host.txt      # generated report name

# create backup directory if it does not exist
if [ -d $bkdir ]; then
  echo "folder exists, continuing..." >> /dev/null
else
  /bin/mkdir -p /home/backup
fi

# Generate a list of sockets for /opt and /var
find /opt -type s > /root/bin/opt_sockets.lst 2>/dev/null
find /var -type s > /root/bin/var_sockets.lst

/usr/bin/clear
echo "" | tee -a "$rep"
echo -e "OES2015 SP1 Backup Report" | tee -a "$rep"
echo -e "Host: $host" | tee -a "$rep"
echo -e "  OS: $osver" | tee -a "$rep"
echo -e " OES: $oesver" | tee -a "$rep"
echo -e "Date: $dsp" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"

# Check for adequate free space on the / [root] partition
echo "" | tee -a "$rep"
echo "Section 5.3.2 -Ensure that there is Adequate Storage Space on the Root Partition" | tee -a "$rep"
echo "Check free space - tolerance is 60% used" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
rup=$(df -h | grep -w "/" | grep -v .host | awk '{ print $5 }')
ru=$(df -h | grep -w "/" | grep -v .host | awk '{ print $5 }' | sed 's/%//')

if [ "$ru" -le 60 ]; then
  echo "The root partition is below the 60% threshold of used space." | tee -a "$rep"
  echo "The root partition is currently consuming $rup of available space." | tee -a "$rep"
else
  echo "The root partition is above the threshold of 60% of used space." | tee -a "$rep"
  echo "Do not proceed with the upgrade to OES2018, the root partition may run out of space." | tee -a "$rep"
  echo "The root partition is currently consuming $rup of available space." | tee -a "$rep"
  echo "Consider cleaning up the root partition or adding space to the server to proceed." | tee -a "$rep"
fi
/bin/sleep 5

# check for available patches for the current OS and OES versions
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.3 - Preparing the Server you are Upgrading" | tee -a "$rep"
echo "Checking for outstanding patches" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
/usr/bin/zypper refresh -s
echo "The following patches are required:" | tee -a "$rep"
/usr/bin/zypper list-patches | tee -a "$rep"
/bin/sleep 5

# Check local ip address and DNS name resolution
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.4 - Check the Server's DNS Name and Name Resolution" | tee -a "$rep"
echo "Check DNS name resolution" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
echo "The local IP Address is $lip" | tee -a "$rep"
echo "The fqdn is $fqdn" | tee -a "$rep"
echo "" | tee -a "$rep"
echo "Testing DNS record via nslookup." | tee -a "$rep"
/usr/bin/nslookup "$lip" | tee -a "$rep"
/usr/bin/nslookup "$fqdn" | tee -a "$rep"
echo "" | tee -a "$rep"
echo "Testing IP and FQDN name resolution via ping" | tee -a "$rep"
/bin/ping -c4 "$fqdn" | tee -a "$rep"
/bin/ping -c4 "$lip" | tee -a "$rep"
echo "Checks complete" | tee -a "$rep"
/bin/sleep 5

# Run the oes_upgrade_check.pl script to synchronize settings
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.8 - Synchronizing the OES Configuration Information before Upgrade" | tee -a "$rep"
echo "Synchronizing changes to the OES configuration made outside of YaST" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
echo y | /opt/novell/oes-install/util/oes_upgrade_check.pl all
echo "Synchronization complete." | tee -a "$rep"
/bin/sleep 5

# Run a ndscheck to ensure eDirectory is healthy
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Basic eDirectory Health Check" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
/opt/novell/eDirectory/bin/ndscheck -a admin.services.mig -W | tee -a "$rep"
/bin/sleep 5

# Prior to upgrading OES2015 SP1 to OES2018 you must backup /etc/, /opt/, /home, /root, and /var/
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.1 - Secure Current Data in /etc, /home, /root, /opt, and /var" | tee -a "$rep"
echo "Beginning backup of /etc/" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
tar jcvf $bkdir/backup_etc_"${host}"_"${date}".tbz /etc/* >> $log 2>> $errlog
echo -e "The backup of /etc/ has completed."  | tee -a "$rep"
/bin/sleep 5

# Backup /home, except /home/backup
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.1 - Secure Current Data in /etc, /home, /root, /opt, and /var"
echo "Beginning backup of /home/" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
tar jcvf $bkdir/backup_home_"${host}"_"${date}".tbz /home/* --exclude=home/backup >> $log 2>> $errlog
echo "Backup of /home/ is complete." | tee -a "$rep"
/bin/sleep 5

# Backup of /root
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.1 - Secure Current Data in /etc, /home, /root, /opt, and /var"
echo "Beginning backup of /root/" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
tar jcvf $bkdir/backup_root_"${host}"_"${date}".tbz /root/* --exclude=root/shared >> $log 2>> $errlog
echo "Backup of /root/ is complete." | tee -a "$rep"
/bin/sleep 5

# Backup of /opt
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.1 - Secure Current Data in /etc, /hone, /root, /opt, and /var"
echo "Beginning backup of /opt/" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
tar jcvf $bkdir/backup_opt_"${host}"_"${date}".tbz /opt/* --exclude=opt/novell/nss/mnt --exclude=opt/NAI --exclude=opt/scripts/os/isos --exclude-from=/root/bin/opt_sockets.lst >> $log 2>> $errlog
echo "Backup of /opt/ is complete." | tee -a "$rep"
/bin/sleep 5

# Backup of /var
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Section 5.3.1 - Secure Current Data in /etc, /hone, /root, /opt, and /var"
echo "Beginning backup of /var/" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
tar jcvf $bkdir/backup_var_"${host}"_"${date}".tbz /var/* --exclude=var/opt/novell/eDirectory/data/dib --exclude=var/lib/ntp/proc --exclude=/var/spool --exclude=var/run --exclude=var/opt/novell/ganglia/rrds --exclude-from=/root/bin/var_sockets.lst >> $log 2>> $errlog
echo "Backup of /var/ is complete." | tee -a "$rep"
/bin/sleep 5

# Run a final supportconfig
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Create a supportconfig to go along with the backup files under ${bkdir}" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
echo ""
echo "Please standby..."
echo ""
/sbin/supportconfig -QR /root/shared/backup
echo ""
echo "Finished."
echo ""
echo -e "A supportconfig has been created for this backup operation" | tee -a "$rep"
/bin/sleep 5

# Create a single tar ball of all the files in /root/shared/backup
/usr/bin/clear
echo "" | tee -a "$rep"
echo "Create a single archive file under ${bkdir}" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
tar --ignore-failed-read -f ${bkdir}/pre-oes2018-backup-"${host}"-"${date}".tbz -jcv ${bkdir}/backup_etc_*.tgz ${bkdir}/backup_root_*.tgz ${bkdir}/backup_home_*.tgz ${bkdir}/backup_var_*.tgz ${bkdir}/backup_opt_*.tgz ${bkdir}/nts_* >> $log 2>> $errlog
echo -e "A single tarball has been created for this backup operation" | tee -a "$rep"
/bin/sleep 5

# Remove individual tarballs
/bin/rm -rf ${bkdir}/backup_etc*.tbz
/bin/rm -rf ${bkdir}/backup_root*.tbz
/bin/rm -rf ${bkdir}/backup_home*.tbz
/bin/rm -rf ${bkdir}/backup_var*.tbz
/bin/rm -rf ${bkdir}/backup_opt*.tbz
/bin/rm -rf ${bkdir}/nts_*

# Completion message
/usr/bin/clear
echo "" | tee -a "$rep"
echo "OES2018 Pre Upgrade Checks complete" | tee -a "$rep"
echo "------------------------------------------------------" | tee -a "$rep"
echo "OES2018 upgrade requirements have been met." | tee -a "$rep"
echo "Please review the report generated before proceeding" | tee -a "$rep"
echo "with the actual upgrade. You should also move the report" | tee -a "$rep"
echo "and tarball off the server prior to upgrade and store in" | tee -a "$rep"
echo "safe place in case of a failure during the upgrade." | tee -a "$rep"
echo "The report and tarball can be found here: $rep" 
echo "" | tee -a "$rep"

# cleanup files
/bin/rm -f /root/bin/*.lst

# Finished
exit 0
