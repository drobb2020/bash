#!/bin/bash - 
#===============================================================================
#
#          FILE: preupbk-0.1.0.sh
# 
#         USAGE: ./preupbk-0.1.0.sh 
# 
#   DESCRIPTION: Performs the required OES2015 pre-upgrade backups of /etc, /opt,
#                /var, /home, and /root
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
#  LAST UPDATED: Thu Mar 03 2016 13:10
#      REVISION: 6
#     SCRIPT ID: ---
# SSC UNIQUE ID: 28
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.6                                   # version number of the script
sid=000                                         # personal script id number
uid=28                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
dsp=$(date +'%A %B %d, %Y')                     # special date/time stamp
date=$(date +%Y%m%d%H%M)                        # date-time stamp
host=$(hostname)                                # host name of local server
lip=$(hostname -i)                              # local IP Address
fqdn=$(hostname -f)                             # fully qualified domain hostname
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
osver=$(cat /etc/os-release | grep PRETTY | cut -f 2 -d "=" | awk '{print $1,$2,$3,$4,$5,$6}' | sed 's/"//g') # installed OS version
oesver=$(cat /etc/novell-release | grep Novell) # installed OES verison
log='/var/log/preupbk.log'                      # logging (if required)
errlog='/var/log//preupbk.error.log'            # tar error log file
bkdir=/root/shared/backup                       # local backup destination
rep=$bkdir/OES2018_Backup_report-$host.txt      # generated report name

# Generate a list of sockets for /opt and /var
find /opt -type s > /root/bin/opt_sockets.lst 2>/dev/null
find /var -type s > /root/bin/var_sockets.lst

echo "" | tee -a $rep
echo -e "OES2015 SP1 Backup Report" | tee -a $rep
echo -e "Host: $host" | tee -a $rep
echo -e "  OS: $osver" | tee -a $rep
echo -e " OES: $oesver" | tee -a $rep
echo -e "Date: $dsp" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep

# Check local ip address and DNS name resolution
echo "" | tee -a $rep
echo "Check DNS name resolution" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
echo "The local IP Address is $lip" | tee -a $rep
echo "The fqdn is $fqdn" | tee -a $rep
echo "Testing DNS record now." | tee -a $rep
/bin/ping -c4 $fqdn | tee -a $rep
echo "Check complete" | tee -a $rep

# Run the oes_upgrade_check.pl script to synchronize settings
echo "" | tee -a $rep
echo "Synchronizing changes to the OES configuration made outside of YaST" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
echo y | /opt/novell/oes-install/util/oes_upgrade_check.pl all
echo "Synchronization complete." | tee -a $rep

# Prior to upgrading OES2015  SP1 to OES2018 you must backup /etc/, /opt/, and /var/
echo "" | tee -a $rep
echo "Begining backup of /etc/" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
tar jcvf $bkdir/backup_etc_${host}_${date}.tbz /etc/* >> $log 2>> $errlog
echo -e "The backup of /etc/ has completed."  | tee -a $rep

# Backup /home, except /home/backup
echo "" | tee -a $rep
echo "Beginning backup of /home/" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
tar jcvf $bkdir/backup_home_${host}_${date}.tbz /home/* --exclude=home/backup >> $log 2>> $errlog
echo "Backup of /home/ is complete." | tee -a $rep

# Backup of /root
echo "" | tee -a $rep
echo "Beginning backup of /root/" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
tar jcvf $bkdir/backup_root_${host}_${date}.tbz /root/* --exclude=root/shared >> $log 2>> $errlog
echo "Backup of /root/ is complete." | tee -a $rep

# Backup of /opt
echo "" | tee -a $rep
echo "Beginning backup of /opt/" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
tar jcvf $bkdir/backup_opt_${host}_${date}.tbz /opt/* --exclude=opt/novell/nss/mnt --exclude=opt/NAI --exclude=opt/scripts/os/isos --exclude-from=/root/bin/opt_sockets.lst >> $log 2>> $errlog
echo "Backup of /opt/ is complete." | tee -a $rep

# Backup of /var
echo "" | tee -a $rep
echo "Beginning backup of /var/" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
tar jcvf $bkdir/backup_var_${host}_${date}.tbz /var/* --exclude=var/opt/novell/eDirectory/data/dib --exclude=var/lib/ntp/proc --exclude=/var/spool --exclude=var/run --exclude=var/opt/novell/ganglia/rrds --exclude-from=/root/bin/var_sockets.lst >> $log 2>> $errlog
echo "Backup of /var/ is complete." | tee -a $rep

/bin/sleep 5

# Run a final supportconfig
echo "" | tee -a $rep
echo "Create a supportconfig to go along with the backup files under ${bkdir}" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
echo ""
echo "Please standby..."
echo ""
/sbin/supportconfig -QR /root/shared/backup
echo ""
echo "Finished."
echo ""
echo -e "A supportconfig has been created for this backup operation" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep

/bin/sleep 5

# Create a single tar ball of all the files in /root/shared/backup
echo "" | tee -a $rep
echo "Create a single archive file under ${bkdir}" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
tar --ignore-failed-read -f ${bkdir}/pre-oes2018-backup-${host}-${date}.tbz -jcv ${bkdir}/backup_etc_*.tgz ${bkdir}/backup_root_*.tgz ${bkdir}/backup_home_*.tgz ${bkdir}/backup_var_*.tgz ${bkdir}/backup_opt_*.tgz ${bkdir}/nts_* >> $log 2>> $errlog
echo -e "A single tarball has been created for this backup operation" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep

/bin/sleep 5

# Remove individual tarballs
echo -e "Cleaning up individual tarballs"
/bin/rm -rf ${bkdir}/backup_etc*.tbz
/bin/rm -rf ${bkdir}/backup_root*.tbz
/bin/rm -rf ${bkdir}/backup_home*.tbz
/bin/rm -rf ${bkdir}/backup_var*.tbz
/bin/rm -rf ${bkdir}/backup_opt*.tbz
/bin/rm -rf ${bkdir}/nts_*

# Completion message
/usr/bin/clear
echo "" | tee -a $rep
echo "======================================================" | tee -a $rep
echo "OES2018 pre upgrade filesysten backups are complete" | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
echo "OES2018 Pre upgrade filesystem backup requirements" | tee -a $rep
echo "have been met. The tar files will be moved to the" | tee -a $rep
echo "appropriate deployment server and stored under:" | tee -a $rep
echo "/root/shared/sc_repo/oes2015_backups"  | tee -a $rep
echo "------------------------------------------------------" | tee -a $rep
echo "The report can be found here: $rep" 
echo "------------------------------------------------------"
echo "" | tee -a $rep

# cleanup files
/bin/rm -f /root/bin/*.lst

# Finished
exit 1

