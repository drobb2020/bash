#!/bin/bash - 
#===============================================================================
#
#          FILE: oeshealth.sh
# 
#         USAGE: ./oeshealth.sh 
# 
#   DESCRIPTION: Create an automated health report for OES Linux servers
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
#       OPTIONS: 0 3 * * 1,3,5 /root/bin/oeshealth.sh   # for weekly execution
#                * * 2 * * /root/bin/oeshealth.sh       # for monthly execution
#  REQUIREMENTS: The file /root/bin/oes-healthmsg.txt must be present
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Mar 22 2011 11:53
#  LAST UPDATED: Thu Mar 15 2018 14:14
#       VERSION: 0.2.1
#     SCRIPT ID: 050
# SSC SCRIPT ID: 00
#===============================================================================
version=0.2.1                                    # version number of the script
host=$(hostname)                                 # hostname of the local server
mfrom=OES-Health-Reports                         # email sender
email=root                                       # email recipient(s)
today=$(date +"%d-%m-%Y")                        # today datestamp
repdir=/root/reports                             # report directory
repname=OESHealth                                # report name
ndsconf=/etc/opt/novell/eDirectory/conf/nds.conf # path to nds configuration files
ndslog=/var/opt/novell/eDirectory/log/ndsrepair.log  # path to nds repair log
ndsbin=/opt/novell/eDirectory/bin                # path to nds binaries
nsssbin=/opt/novell/nss/sbin                     # path to NSS supervisor binaries
report=${repdir}/${repname}-${host}-${today}.txt # full report path and name
osver=$(grep VERSION /etc/SuSE-release | cut -f 2 -d "=" | sed -e 's/^[ \t]*//') # OS version
oesver=$(grep VERSION /etc/novell-release | awk '{print $NF}') # OES Version
#===============================================================================
# Functions
addspace() { 
  echo "" >> "$report"
}

# Check if user is root
if [ $EUID != "root" ]; then
  echo "You must be root to run this script. Exiting..."
  echo "Please sudo to root and try again."
  exit 1
fi

# Create report directory if it doesn't exist
if [ ! -d $repdir ]; then
  /bin/mkdir -p $repdir
fi

# Delete old report
if [ -e "$report" ]; then
  /bin/rm "$report"
fi

# Delete old ndsrepair.log
if [[ -e "$ndsconf"  && -e "$ndslog" ]]; then
  /bin/rm "$ndslog"
fi

# Create new report and set date timestamp
addspace
echo "--[ SLES & OES Health Report v${version} ]------------------------------------------" >> "$report"
echo "--[ Report started at: $(date +'%a, %b, %d, %Y %k:%M:%S') ]----------------------------" >> "$report"
addspace

# Report SLES release
echo "--[ SLES Version: ]--------------------------------------------" >> "$report"
cat /etc/SuSE-release >> "$report"
addspace

# Linux Kernel release
echo "--[ Kernel Version: ]-----------------------------------------" >> "$report"
echo "Kernel: $(/bin/uname -r)" >> "$report"
echo "Architecture: $(/bin/uname -i)" >> "$report"
addspace

# IP Address and Hostname
echo "--[ IP Address and Hostname of server: ]----------------------------------------" >> "$report"
echo "IP Address: $(hostname -i)" >> "$report"
echo "Hostname: $(hostname -f)" >> "$report"
addspace

# Report SLES uptime statistics
echo "--[ Server Uptime: ]------------------------------------------------------------" >> "$report"
/usr/bin/uptime >> "$report"
addspace

# Report Memory usage in Megabytes
echo "--[ Memory Usage: ]-------------------------------------------------------------" >> "$report"
/usr/bin/free -mot >> "$report"
addspace

# Report Virtual memory statistics
echo "--[ Virtual Memory Statistics: ]------------------------------------------------" >> "$report"
/usr/bin/vmstat 2 4 >> "$report"
addspace

# Report disk space usage
echo "--[ File System Space Usage: ]--------------------------------------------------" >> "$report"
/bin/df -lh >> "$report"
addspace

# Report inode usage
echo "--[ Inode usage on Linux file systems: ]----------------------------------------" >> "$report"
/bin/df -i | awk 'NR>1{exit};1' >> "$report"
/bin/df -i | sed -n '/dev\/sd/p' >> "$report"
addspace

# Report on daemons
echo "--[ Critical Daemon Status for SLES Services: ]---------------------------------" >> "$report"

# apache web server
if [ -e /etc/init.d/apache2 ]; then
  SNRWEB=$(/sbin/chkconfig -l apache2 | grep "$RL":on | cut -f 24 -d " ")
  if [ -z "$SNRWEB" ]; then
    echo "Apache is installed but not configured to run." >> "$report"
  else
    APACHE2=$(pgrep -c httpd)
    if [ "$APACHE2" -ge 1 ]; then
      echo "Apache Web Server is running" >> "$report"
    else
      echo "Apache Web Server appears to be dead or intentionally stopped, please investigate." >> "$report"
    fi
  fi
fi

# cron daemon
CRON=$(pgrep -c cron)
if [ "$CRON" -ge 1 ]; then
  echo "Cron daemon is running" >> "$report"
else
  echo "Cron appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Network Time Protocol (ntp)
NTP=$(pgrep -c ntpd)
if [ "$NTP" -ge 1 ]; then
  echo "Network Time Protocol (ntp) is running" >> "$report"
else
  echo "Network Time Protocol (ntp) appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Service Location Protocol (slp)
SLP=$(pgrep -c slpd)
if [ "$SLP" -ge 1 ]; then
  echo "Service Location Protocol (slp) is running" >> "$report"
else
  echo "Service Location Protocol (slp) appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Secure Shell (ssh)
SSH=$(pgrep -c sshd)
if [ "$SSH" -ge 1 ]; then
  echo "Secure Shell Daemon (sshd) is running" >> "$report"
else
  echo "Secure Shell Daemon (sshd) appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# OWCIMOMD or SFCB Daemons
if [ "$osver" -eq 10 ]; then
  CIMOM=$(pgrep -c owcimomd)
  if [ "$CIMOM" -ge 1 ]; then
    echo "Open Web CIMON Daemon (owcimond) is running" >> "$report"
  else
    echo "Open Web CIMOM Daemon (owcimond) appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
else
  SFCB=$(pgrep -c sfcbd)
  if [ "$SFCB" -ge 1 ]; then
    echo "Small Footprint CIM Broker (sfcb) is running" >> "$report"
  else
    echo "Small Footprint CIM Broker (sfcb) appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
fi

# Name service cache
NSCD=$(pgrep -c nscd)
if [ "$NSCD" -ge 1 ]; then
  echo "Name Service Cache Daemon is running" >>"$report"
else
  echo "Name Service Cache Daemon appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# pure-ftpd daemon
if [ -e /etc/init.d/pure-ftpd ]; then
  SNRFTP=$(/sbin/chkconfig -l pure-ftpd | grep "$RL":on | cut -f 24 -d " ")
  if [ -z "$SNRFTP" ]; then
    echo "pure-ftpd is installed but not configured to run." >> "$report"
  else
    PFTPD=$(pgrep -c pure-ftpd)
    if [ "$PFTPD" -ge 1 ]; then
      echo "pure-ftpd service is running" >> $"$report"
    else
      echo "pure-ftpd service appears to be dead or intentionally stopped, please investigate." >> "$report"
    fi
  fi
fi
addspace

echo "--[ Critical Daemon Status for OES Services: ]----------------------------------" >>"$report"
# eDirectory (ndsd)
if [ -e $ndsconf ]; then
  NDSD=$(pgrep -c ndsd)
  if [ "$NDSD" -ge 1 ]; then
    echo "eDirectory daemon is running" >> "$report"
  else
    echo "eDirectory daemon appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Linux User Management
LUM=$(pgrep -c namcd)
if [ "$LUM" -ge 1 ]; then
  echo "Linux User Management is running" >> "$report"
else
  echo "Linux User Management appears to be dead or intentionally stopped, please investigate" >> "$report"
fi

# NCP2NSS
N2N=$(pgrep -c ncp2nss)
if [ "$N2N" -ge 1 ]; then
  echo "The eDir to NSS connector (ncp2nss) is running" >> "$report"
else
  echo "The eDir to NSS connector (ncp2nss appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# NDPAPP
NDPAPP=$(pgrep -c ndpapp)
if [ "$NDPAPP" -ge 1 ]; then
  echo "The LUM to NSS connector (ndpapp) is running" >> "$report"
else
  echo "The LUM to NSS connector (ndpapp) appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# CIFS
CIFS=$(pgrep -c cifsd)
if [ "$CIFS" -ge 1 ]; then
  echo "Novell CIFS is running" >> "$report"
else
  echo "Novell CIFS appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Novell web server (httpstk)
HTTPSTK=$(pgrep -c httpstkd)
if [ "$HTTPSTK" -ge 1 ]; then
  echo "Novell Web Server is running" >> "$report"
else
  echo "Novell Web Server appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Novell Backup Agent (smdrd) 
SMDRD=$(pgrep -c smdrd)
if [ "$SMDRD" -ge 1 ]; then
  echo "Novell Backup Agent (smdrd) is running" >> "$report"
else
  echo "Novell Backup Agent (smdrd) appears to be dead or intentionally stopped, please investigate." >> "$report"
fi

# Novell Tomcat5 or 6
if [ "$osver" -eq 10 ]; then
  TC5=$(pgrep -c tomcat5)
  if [ "$TC5" -ge 1 ]; then
    echo "Novell Tomcat5 is running" >> "$report"
  else
    echo "Novell Tomcat5 appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
else
  TC6=$(pgrep -c tomcat6)
  if [ "$TC6" -ge 1 ]; then
    echo "Novell Tomcat6 is running" >> "$report"
  else
    echo "Novell Tomcat6 appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
fi
else
  echo "OES Services are not installed on this server" >> "$report"
fi

# GroupWise Agents
if [ -e /etc/init.d/grpwise ] ; then
  DVA=$(pgrep -c 'gwdva')
  POA=$(pgrep -c 'gwpoa')
  MTA=$(pgrep -c 'gwmta')
  GWIA=$(pgrep -c 'gwia')
  if [ "$DVA" -ge 1 ]; then
    echo "GroupWise Document Viewer Agent is running" >> "$report"
  else
    echo "GroupWise Document Viewer Agent appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
  if [ "$POA" -ge 1 ]; then
    echo "GroupWise Post Office Agent is running" >> "$report"
  else
    echo "GroupWise Post Office Agent appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
  if [ "$MTA" -ge 1 ]; then
    echo "GroupWise Message Transfer Agent is running" >> "$report"
  else
    echo "GroupWise Message Transfer Agent appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
  if [ "$GWIA" -ge 1 ]; then
    echo "GroupWise Internet Agent is running" >> "$report"
  else
    echo "GroupWise Internet Agent appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
else
  echo "GroupWise is not installed on this server." > /dev/null
fi

# GroupWise Monitor
if [ -e /etc/init.d/grpwise-ma ]; then
  GWMA=$(pgrep -c gwmon)
  if [ "$GWMA" -ge 1 ]; then
    echo "GroupWise Monitor Agent is running" >> "$report"
  else
    echo "GroupWise Monitor Agent appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
else
  echo "GroupWise Monitor is not installed on this server" > /dev/null
fi

# Novell Messenger Agent
if [ -e /etc/init.d/novell-nmma ]; then
  MA=$(pgrep -c nmma)
  if [ "$MA" -ge 1 ]; then
    echo "Novell Messenger Agent is running" >> "$report"
  else
    echo "Novell Messenger Agent appears to be dead or intentionally stopped, please investigate." >> "$report"
  fi
else
  echo "Novell Messenger is not installed on this server" > /dev/null
fi

# Novell Messenger Archive Agent
if [ -e /etc/init.d/novell-nmaa ]; then
  AA=$(pgrep -c nmaa)
  if [ "$AA" -ge 1 ]; then
    echo "Novell Messenger Archive Agent is running" >> "$report"
  else
    echo "Novell Messenger Archive Agent appears to be dead or intentionally shutdown, please investigate." >> "$report"
  fi
else
  echo "Novell Messenger Archive Agent is not installed on this server" > /dev/null
fi
addspace

# Report OES eDirectory status
echo "--[ NCP / NSS / eDir Status: ]--------------------------------------------------" >> "$report"
if [ -e $ndsconf ]; then
  echo "--[ OES Release: ]--------------------------------------------------------------" >> "$report"
  cat /etc/novell-release >> "$report"
  addspace
  sleep 2
  echo "--[ NCP Connections ]-----------------------------------------------------------" >> "$report"
  /sbin/ncpcon "connections" 2>/dev/null 1>> "$report"
  addspace
  echo "--[ NCP Statistics ]------------------------------------------------------------" >> "$report"
  /sbin/ncpcon "stats" 2>/dev/null 1>> "$report"
  addspace
  echo "--[ NCP Thread Usage ]----------------------------------------------------------" >> "$report"
  /sbin/ncpcon threads 2>/dev/null 1>> "$report"
  addspace
  sleep 2
  echo "--[ NSS Space Information ]-----------------------------------------------------" >> "$report"
  echo -e 'c\nclear\nC\n\nexit' | $nsssbin/nsscon
  sleep 2
  echo -e 'c\nSpaceInformation\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> "$report"
  sleep 2
  echo "--[ Current NDS Status: ]-------------------------------------------------------" >> "$report"
  $ndsbin/ndsstat -s | awk 'NR > 7' >> "$report"
  addspace
  sleep 4
  echo "--[ Running NDS Modules ]-------------------------------------------------------" >> "$report"
  $ndsbin/ndstrace -c "modules" | sort >> "$report"
  addspace
  sleep 4
  echo "--[ NDS Thread Pool ]-----------------------------------------------------------" >> "$report"
  /opt/novell/eDirectory/bin/ndstrace -c threads | awk 'NR < 7' >> "$report"
  addspace
  sleep 4
  echo "--[ Timesync Status: ]----------------------------------------------------------" >> "$report" 
  $ndsbin/ndsrepair --config-file $ndsconf -T | awk 'NR > 16' >> "$report"
  addspace
  sleep 4
  echo "--[ Replica Sync Status: ]------------------------------------------------------" >> "$report" 
  $ndsbin/ndsrepair --config-file $ndsconf -E | awk 'NR > 10' >> "$report"
  addspace
  sleep 4
  echo "--[ Obituary Status: ]----------------------------------------------------------" >> "$report" 
  $ndsbin/ndsrepair --config-file $ndsconf -C -Ad -A | awk 'NR > 12' >> "$report"
else
  echo "eDirectory and it's related services are not installed on this server" >> "$report"
fi
addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]---------------------------" >> "$report"
addspace

# mail message
function mail_body1() { 
echo -e "\nPlease find attached today's $oesver Health Report.

\n\nPlease store this file for historical reference.

\n\nThe file should be copied to this location:
\nT:\Reports\OES\HealthReports

\n--[ Uptime and Memory Report ]------------------------------------------------
\nServer uptime represents the time the server has been up since the last reboot, the number of users are users logged into the server, not NCP users. The load average is a sample for the last minute, 5 minutes, and 15 minutes.

\n\nMemory usage displays the amount of free and used physical and swap memory in the system, as well as the buffers used by the kernel. The shared memory column is obsolete and always shows 0.

\n\nVirtual memory statistics reports information about processes, memory, paging, block IO, traps, and CPU activity. Please see man vmstat for the definitions of the column headings.

\n\n--[ Partition and Inode Report ]----------------------------------------------
\nPlease review the file and act on any partition that is reporting more than 75% full.

\n\nUse the find command to locate large files:

\n\nfind / -size +10240000c -exec du -h {} \; | less

\n\nThis command will find all files from the root of the drive on down that are larger than 10 MB.
\nThe command can be issued from a command line using either a terminal window on the GUI desktop (requires you to be at the console) or by using PuTTY. For the command to work completely you must be authenticated as root.

\n\nFree inodes are required to create new files and folders on Linux. Please review the list of used and free inodes for each Linux partition, and if you are running low on inodes you will need to formulate a plan to correct the condition.

\n\n--[ Disk IO Statistics ]------------------------------------------------------
\nThis report is generated using iostat, and gives a single point-in-time view of the disk IO for all partitions.

\n\n--[ CPU Statistics ]----------------------------------------------------------
\nThis report is generated using mpstat and gives a point-in-time view of the processor IO for all processors.

\n\n--[ Daemon Report (SLES and OES) ]--------------------------------------------
\nPlease review the Daemon Services section and ensure all critical services hosted by this server are running and responding correctly. If a daemon is stopped or dead, please PuTTY to the server and restart the affected service.

\n\n--[ eDirectory Status ]-------------------------------------------------------
\nPlease review the OES2 Health section and act on any eDirectory problems. If you are unsure of running these commands by yourself, please contact your System Administrator to ensure you are doing the right thing before doing anything.

\n\nPlease review the file and act on any eDirectory problems.

\nTo fix timesync issues:
\n1. Open a PuTTY session to the server that is not in timesync.
\n2. Authenticate as root
\n3. Run the following command: rcntp restart - this will restart the ntp daemon and bring the server back into sync.
\n4. Run the following command: ndsrepair -T - this will report the timesync status
\n5. Exit the PuTTY session when satisfied

\n\nTo Fix Replica Sync issues:
\n1. Open a PuTTY session to the server that is showing a replica issue.
\n2. Authenticate as root
\n3. Run the following command: ndsrepair -R -c yes -l yes - this is will run a local database repair and check local references with the database locked.
\n4. Run the following command: ndsrepair -E - this will report the replica sync status. If issues are still reported, research the individual error numbers (i.e. -618, 625, etc...)
\n5. Exit the PuTTY session when satisfied

\n\nTo fix stuck obits:
\n1. Open a PuTTY session to the server that is showing obituaries.
\n2. Authenticate as root.
\n3. Run the following command: ndsrepair -C -Ad -OT - this command resets the timestamp on all external references an.d allow the obits to process
\n4. Run the following command: ndsrepair -C -Ad -A  - this will report any remaining external references on the server not fixed by the above timestamp operation.
\n5. Exit the PuTTY session when satisfied.

\n\nIf you are unsure of running these commands by yourself,
\nPlease contact your System Administrator to ensure you are doing the right thing before doing anything.

\n\nThanks,

\n\nOES Health Reports"
}

# e-mail report
mail -s "$host OES Health Report" -a "$report" -r $mfrom $email < /root/bin/oes-healthmsg.txt

# Finished
exit 0
