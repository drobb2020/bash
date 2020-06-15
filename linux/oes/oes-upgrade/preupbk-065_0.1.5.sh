#!/bin/bash - 
#===============================================================================
#
#          FILE: preupbk.sh
# 
#         USAGE: ./preupbk.sh 
# 
#   DESCRIPTION: Performs the required OES2015 pre-upgrade backups of /etc, /boot,
#                /opt, /var, /home, /boot, and /root
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
#  LAST UPDATED: Sun Jun 12 09:15:15 2016 
#      REVISION: 5
#     SCRIPT ID: ---
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.5                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=root                                      # who to send email to (comma separated list)
log='/var/log/preupbk.log'                      # logging (if required)
bkdir='/home/backup'                            # backup destination

function helpme() { 
  echo "WARNING"
  echo "-------------------------------------------------------------------"
  echo "The correct command line syntax is ./preupbk.sh FQDN of server"
  echo "for example: ./preupbk.sh acpic-s2007.ross.rossdev.rcmp-grc.gc.ca"
  echo "The script will now exit, please try again."
  echo "==================================================================="
  exit 1
}

if [ $# -lt 1 ]; then
  helpme
else

# Generate a list of sockets for /opt and /var
find /opt -type s > /root/bin/opt_sockets.lst 2>/dev/null
find /var -type s > /root/bin/var_sockets.lst

# Prior to upgrading OES11 SP2 to OES2015 you must backup /etc/, /opt/, and /var/
echo "======================================================"
echo "--[ Pre OES2015 Upgrade ]-----------------------------"
echo "======================================================"
echo ""
echo "======================================================"
echo "--[ Begining backup of /boot/ ]-----------------------"
echo "======================================================"
tar jcf $bkdir/backup_boot_${host}_$(date +'%Y%m%d_%H%M').tbz /boot/*
echo "======================================================"
echo "Backup of /boot/ is complete."
echo "------------------------------------------------------"
echo ""
echo "======================================================"
echo "--[ Begining backup of /etc/ ]------------------------"
echo "======================================================"
tar jcf $bkdir/backup_etc_${host}_$(date +'%Y%m%d_%H%M').tbz /etc/*
echo "======================================================"
echo "Backup of /etc/ is complete."
echo "------------------------------------------------------"
echo ""
echo "======================================================"
echo "--[ Beginning backup of /home/ ]----------------------"
echo "======================================================"
tar jcf $bkdir/backup_home_${host}_$(date +'%Y%m%d_%H%M').tbz /home/* --exclude=home/backup
echo "======================================================"
echo "Backup of /home/ is complete."
echo "------------------------------------------------------"
echo ""
echo "======================================================"
echo "--[ Beginning backup of /root/ ]----------------------"
echo "======================================================"
tar jcf $bkdir/backup_root_${host}_$(date +'%Y%m%d_%H%M').tbz /root/*
echo "======================================================"
echo "Backup of /root/ is complete."
echo "------------------------------------------------------"
echo ""
echo "======================================================"
echo "--[ Beginning backup of /opt/ ]-----------------------"
echo "======================================================"
tar jcf $bkdir/backup_opt_${host}_$(date +'%Y%m%d_%H%M').tbz /opt/* --exclude=opt/novell/nss/mnt --exclude=opt/NAI --exclude=opt/scripts/os/isos --exclude-from=/root/bin/opt_sockets.lst
echo "======================================================"
echo "Backup of /opt/ is complete."
echo "------------------------------------------------------"
echo ""
echo "======================================================"
echo "--[ Beginning backup of /var/ ]-----------------------"
echo "======================================================"
tar jcf $bkdir/backup_var_${host}_$(date +'%Y%m%d_%H%M').tbz /var/* --exclude=var/opt/novell/eDirectory/data/dib --exclude=var/lib/ntp/proc --exclude=/var/spool --exclude=var/run --exclude=var/opt/novell/ganglia/rrds --exclude-from=/root/bin/var_sockets.lst
echo "======================================================"
echo "Backup of /var/ is complete."
echo "------------------------------------------------------"
/bin/sleep 3
fi

/usr/bin/clear
echo ""
echo "======================================================"
echo "--[ Pre OES2015 Upgrade ]-----------------------------"
echo "======================================================"
echo "Pre upgrade backup requirements have been met. Please" 
echo "store the files in a safe place in case there is an" 
echo "upgrade failure."
echo "------------------------------------------------------"
echo ""

# cleanup files
/bin/rm -f /root/bin/*.lst

# Finished
exit 1

