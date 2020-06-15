#!/bin/bash - 
#===============================================================================
#
#          FILE: oeshealth.sh
# 
#         USAGE: ./oeshealth.sh 
# 
#   DESCRIPTION: Create an automated health report for OES Linux servers
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
#       OPTIONS: 0 3 * * 1,3,5 /root/bin/oeshealth.sh   #for weekly execution
#                * * 2 * * /root/bin/oeshealth.sh       #for monthly execution
#  REQUIREMENTS: The file /root/bin/oes-healthmsg.txt must be present
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Mar 22 2011 11:53
#  LAST UPDATED: Thu Jun 15 2017 10:49
#      REVISION: 28
#     SCRIPT ID: 050
# SSC UNIQUE ID: --
#===============================================================================
version=0.1.28                                       # script revision number
sid=050                                              # personal script id number
uid=00                                               # SSC/RCMP script id number
ts=$(date +"%b %d %T")                               # general date/time stamp
ds=$(date +%a)                                       # abbreviated day of the week, eg Mon
df=$(date +%A)                                       # full day of the week, eg Monday
host=$(hostname)                                     # host name of local server
user=$(whoami)                                       # who is running the script
email=root                                           # who to send email to (comma separated list)
log='/var/log/oeshealth.log'                         # logging (if required)
today=$(date +"%d-%m-%Y")                            # today datestamp
repdir=/root/reports                                 # report directory
repname=OESHealth                                    # report name
ndsconf=/etc/opt/novell/eDirectory/conf/nds.conf     # path to nds configuration files
ndslog=/var/opt/novell/eDirectory/log/ndsrepair.log  # path to nds repair log
ndsbin=/opt/novell/eDirectory/bin                    # path to nds binaries
ndssbin=/opt/novell/eDirectory/sbin                  # path to nds supervisor binaries
nsssbin=/opt/novell/nss/sbin                         # path to NSS supervisor binaries
oesconf=/etc/sysconfig/novell                        # path to OES configuration files
rl=$(/sbin/runlevel | cut -f 2 -d " ")               # runlevel
report=${repdir}/${repname}-${host}-${today}.txt     # full report path and name
osver=$(cat /etc/SuSE-release | grep VERSION | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')
LIST=$(chkconfig --list | grep 5:on | cut -f-1 -d" "|tr -t "\012" "\040")

# Functions
addspace() { echo "" >>$report 
}

# Check if user is root
if [ $user != "root" ]; then
  echo "You must be root to run this script. Exiting..."
  echo "Please sudo to root and try again."
  exit 1
fi

# Create report directory if it doesn't exist
if [ ! -d $repdir ]; then
  /bin/mkdir -p $repdir
fi

# Delete old report
if [ -e $report ]; then
  /bin/rm $report
fi

# Delete old ndsrepair.log
if [[ -e $ndsconf  && -e $ndslog ]]; then
  /bin/rm $ndslog
fi

# Create new report and set date timestamp
addspace
echo "--[ SLES & OES Health Report v${version} ]------------------------------------------" >> $report
echo "--[ Report started at: $(date +'%a, %b, %d, %Y %k:%M:%S') ]----------------------------" >> $report
addspace

# Report SLES release
echo "--[ SLES Version: ]-------------------------------------------------------------" >> $report
cat /etc/SuSE-release >> $report
addspace

# Linux Kernel releaes
echo "--[ Kernel Version: ]-----------------------------------------------------------" >> $report
echo "Kernel: $(/bin/uname -r)" >> $report
echo "Architecture: $(/bin/uname -i)" >>$report
addspace

# IP Address and Hostname
echo "--[ IP Address and Hostname of server: ]----------------------------------------" >>$report
echo "IP Address: $(cat /etc/hosts | grep $host | awk '{print $1F}')" >>$report
echo "Hostname: $(hostname -f)" >>$report
addspace

# Report SLES uptime statistics
echo "--[ Server Uptime: ]------------------------------------------------------------" >>$report
/usr/bin/uptime >>$report
addspace

# Report Memory usage in Megabytes
echo "--[ Memory Usage: ]-------------------------------------------------------------" >>$report
/usr/bin/free -mot >>$report
addspace

# Report Virtual memory statistics
echo "--[ Virtual Memory Statistics: ]------------------------------------------------" >>$report
/usr/bin/vmstat 2 4 >>$report
addspace

# Report disk space usage
echo "--[ File System Space Usage: ]--------------------------------------------------" >>$report
/bin/df -lh >>$report
addspace

# Report inode usage
echo "--[ Inode usage on Linux file systems: ]----------------------------------------" >>$report
/bin/df -i | awk 'NR>1{exit};1' >>$report
/bin/df -i | sed -n '/dev\/sd/p' >>$report
addspace

# Report on daemons
echo "--[ Critical Daemon Status for SLES Services: ]---------------------------------" >>$report
if [ -e /etc/init.d/apache2 ]; then
  SNRWEB=$(/sbin/chkconfig -l apache2 | grep $RL:on | cut -f 24 -d " ")
  if [ -z $SNRWEB ]; then
    echo "Apache is installed but not configured to run." >> $report
  else
    APACHE2=$(ps -ef | grep -v grep | grep -cw httpd)
    if [ $APACHE2 -ge 1 ]; then
      echo "Apache Web Server is running" >> $report
    else
      echo "Apache Web Server appears to be dead or intentionally stopped, please investigate." >>$report
    fi
  fi
fi

# apache web server

# cron daemon
CRON=$(ps -ef | grep -v grep | grep -cw cron)
if [ $CRON -ge 1 ]; then
  echo "Cron daemon is running" >>$report
else
  echo "Cron appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Network Time Protcol (ntp)
NTP=$(ps -ef | grep -v grep | grep -cw ntpd)
if [ $NTP -ge 1 ]; then
  echo "Network Time Protocol (ntp) is running" >>$report
else
  echo "Network Time Protocol (ntp) appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Service Location Protcol (slp)
SLP=$(ps -ef | grep -v grep | grep -cw slpd)
if [ $SLP -ge 1 ]; then
  echo "Service Location Protocol (slp) is running" >>$report
else
  echo "Service Location Protocol (slp) appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Secure Shell (ssh)
SSH=$(ps -ef | grep -v grep | grep -cw sshd)
if [ $SSH -ge 1 ]; then
  echo "Secure Shell Daemon (sshd) is running" >>$report
else
  echo "Secure Shell Daemon (sshd) appears to be dead or intentionally stopped, please investigate." >>$report
fi

# OWCIMOMD or SFCB Daemons
if [ $osver -eq 10 ]; then
  CIMOM=$(ps -ef | grep -v grep | grep -cw owcimomd)
  if [ $CIMOM -ge 1 ]; then
    echo "Open Web CIMON Daemon (owcimond) is running" >> $report
  else
    echo "Open Web CIMOM Daemon (owcimond) appears to be dead or intentionally stopped, please investigate." >>$report
  fi
else
  SFCB=$(ps -ef | grep -v grep | grep -cw sfcbd)
  if [ $SFCB -ge 1 ]; then
    echo "Small Footprint CIM Broker (sfcb) is running" >>$report
  else
    echo "Small Footprint CIM Broker (sfcb) appears to be dead or intentionally stopped, please investigate." >>$report
  fi
fi

# Name service cache
NSCD=$(ps -ef | grep -v grep | grep -cw nscd)
if [ $NSCD -ge 1 ]; then
  echo "Name Service Cache Daemon is running" >>$report
else
  echo "Name Service Cache Daemon appears to be dead or intentionally stopped, please investigate." >>$report
fi

# pure-ftpd daemon
if [ -e /etc/init.d/pure-ftpd ]; then
  SNRFTP=$(/sbin/chkconfig -l pure-ftpd | grep $RL:on | cut -f 24 -d " ")
  if [ -z $SNRFTP ]; then
    echo "pure-ftpd is installed but not configured to run." >> $report
  else
    PFTPD=$(ps -ef | grep -v grep | grep -cw pure-ftpd)
    if [ $PFTPD -ge 1 ]; then
      echo "pure-ftpd service is running" >>$report
    else
      echo "pure-ftpd service appears to be dead or intentionally stopped, please investigate." >>$report
    fi
  fi
fi
addspace

echo "--[ Critical Daemon Status for OES Services: ]----------------------------------" >>$report
# eDirectory (ndsd)
if [ -e $ndsconf ]; then
  NDSD=$(ps -ef | grep -v grep | grep -cw ndsd)
  if [ $NDSD -ge 1 ]; then
    echo "eDirectory daemon is running" >>$report
  else
    echo "eDirectory daemon appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Linux User Management
LUM=$(ps -ef | grep -v grep | grep -cw namcd)
if [ $LUM -ge 1 ]; then
  echo "Linux User Management is running" >>$report
else
  echo "Linux User Management appears to be dead or intentionally stopped, please investigate" >>$report
fi

# NCP2NSS
N2N=$(ps -ef | grep -v grep | grep -cw ncp2nss)
if [ $N2N -ge 1 ]; then
  echo "The eDir to NSS connector (ncp2nss) is running" >>$report
else
  echo "The eDir to NSS connector (ncp2nss appears to be dead or intentionally stopped, please investigate." >>$report
fi

# NDPAPP
NDPAPP=$(ps -ef | grep -v grep | grep -cw ndpapp)
if [ $NDPAPP -ge 1 ]; then
  echo "The LUM to NSS connector (ndpapp) is running" >>$report
else
  echo "The LUM to NSS connector (ndpapp) appears to be dead or intentionally stopped, please investigate." >>$report
fi

# CIFS
CIFS=$(ps -ef | grep -v grep | grep -cw cifsd)
if [ $CIFS -ge 1 ]; then
  echo "Novell CIFS is running" >>$report
else
  echo "Novell CIFS appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Novell web server (httpstk)
HTTPSTK=$(ps -ef | grep -v grep | grep -cw httpstkd)
if [ $HTTPSTK -ge 1 ]; then
  echo "Novell Web Server is running" >>$report
else
  echo "Novell Web Server appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Novell Backup Agent (smdrd) 
SMDRD=$(ps -ef | grep -v grep | grep -cw smdrd)
if [ $SMDRD -ge 1 ]; then
  echo "Novell Backup Agent (smdrd) is running" >>$report
else
  echo "Novell Backup Agent (smdrd) appears to be dead or intentionally stopped, please investigate." >>$report
fi

# Novell Tomcat5 or 6
if [ $osver -eq 10 ]; then
  TC5=$(ps -ef | grep -v grep | grep -cw tomcat5)
  if [ $TC5 -ge 1 ]; then
    echo "Novell Tomcat5 is running" >>$report
  else
    echo "Novell Tomcat5 appears to be dead or intentionally stopped, please investigate." >>$report
  fi
else
  TC6=$(ps -ef | grep -v grep | grep -cw tomcat6)
  if [ $TC6 -ge 1 ]; then
    echo "Novell Tomcat6 is running" >>$report
  else
    echo "Novell Tomcat6 appears to be dead or intentionally stopped, please investigate." >>$report
  fi
fi
else
  echo "OES Services are not installed on this server" >> $report
fi

# GroupWise Agents
if [ -e /etc/init.d/grpwise ] ; then
  DVA=$(ps -ef | grep -v grep | grep -cw 'gwdva')
  POA=$(ps -ef | grep -v grep | grep -cw 'gwpoa')
  MTA=$(ps -ef | grep -v grep | grep -cw 'gwmta')
  GWIA=$(ps -ef | grep -v grep | grep -cw 'gwia')
  if [ $DVA -ge 1 ]; then
    echo "GroupWise Document Viewer Agent is running" >>$report
  else
    echo "GroupWise Document Viewer Agent appears to be dead or intentionally stopped, please investigate." >>$report
  fi
  if [ $POA -ge 1 ]; then
    echo "GroupWise Post Office Agent is running" >>$report
  else
    echo "GroupWise Post Office Agent appears to be dead or intentionally stopped, please investigate." >>$report
  fi
  if [ $MTA -ge 1 ]; then
    echo "GroupWise Message Transfer Agent is running" >>$report
  else
    echo "GroupWise Message Transfer Agent appears to be dead or intentionally stopped, please investigate." >>$report
  fi
  if [ $GWIA -ge 1 ]; then
    echo "GroupWise Internet Agent is running" >>$report
  else
    echo "GroupWise Internet Agent appears to be dead or intentionally stopped, please investigate." >>$report
  fi
else
  echo "GroupWise is not installed on this server." > /dev/null
fi

# GroupWise Monitor
if [ -e /etc/init.d/grpwise-ma ]; then
  GWMA=$(ps -ef | grep -v grep | grep -cw gwmon)
  if [ $GWMA -ge 1 ]; then
    echo "GroupWise Monitor Agent is running" >>$report
  else
    echo "GroupWise Monitor Agent appears to be dead or intentionally stopped, please investigate." >>$report
  fi
else
  echo "GroupWise Monitor is not installed on this server" > /dev/null
fi

# Novell Messenger Agent
if [ -e /etc/init.d/novell-nmma ]; then
  MA=$(ps -ef | grep -v grep | grep -cw nmma)
  if [ $MA -ge 1 ]; then
    echo "Novell Messenger Agent is running" >>$report
  else
    echo "Novell Messenger Agent appears to be dead or intentionally stopped, please investigate." >>$report
  fi
else
  echo "Novell Messenger is not installed on this server" > /dev/null
fi

# Novell Messenger Archive Agent
if [ -e /etc/init.d/novell-nmaa ]; then
  AA=$(ps -ef | grep -v grep | grep -cw nmaa)
  if [ $AA -ge 1 ]; then
    echo "Novell Messenger Archive Agent is running" >>$report
  else
    echo "Novell Messenger Archive Agent appears to be dead or intentionally shutdown, please investigate." >>$report
  fi
else
  echo "Novell Messenger Archive Agent is not installed on this server" > /dev/null
fi
addspace

# Report OES eDirectory status
echo "--[ NCP / NSS / eDir Status: ]--------------------------------------------------" >> $report
if [ -e $ndsconf ]; then
  echo "--[ OES Release: ]--------------------------------------------------------------" >>$report 
  cat /etc/novell-release >>$report
  addspace
  sleep 2
  echo "--[ NCP Connections ]-----------------------------------------------------------" >>$report
  /sbin/ncpcon "connections" 2>/dev/null 1>>$report
  addspace
  echo "--[ NCP Statistics ]------------------------------------------------------------" >>$report
  /sbin/ncpcon "stats" 2>/dev/null 1>>$report
  addspace
  echo "--[ NCP Thread Usage ]----------------------------------------------------------" >>$report
  /sbin/ncpcon threads 2>/dev/null 1>>$report
  addspace
  sleep 2
  echo "--[ NSS Space Information ]-----------------------------------------------------" >>$report
  echo -e 'c\nclear\nC\n\nexit' | $nsssbin/nsscon
  sleep 2
  echo -e 'c\nSpaceInformation\nC\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $report
  sleep 2
  echo "--[ Current NDS Status: ]-------------------------------------------------------" >>$report 
  $ndsbin/ndsstat -s | awk 'NR > 7' >>$report
  addspace
  sleep 4
  echo "--[ Running NDS Modules ]-------------------------------------------------------" >>$report
  $ndsbin/ndstrace -c "modules" | sort >>$report
  addspace
  sleep 4
  echo "--[ NDS Thread Pool ]-----------------------------------------------------------" >>$report
  /opt/novell/eDirectory/bin/ndstrace -c threads | awk 'NR < 7' >>$report
  addspace
  sleep 4
  echo "--[ Timesync Status: ]----------------------------------------------------------" >>$report 
  $ndsbin/ndsrepair --config-file $ndsconf -T | awk 'NR > 16' >>$report
  addspace
  sleep 4
  echo "--[ Replica Sync Status: ]------------------------------------------------------" >>$report 
  $ndsbin/ndsrepair --config-file $ndsconf -E | awk 'NR > 10' >>$report
  addspace
  sleep 4
  echo "--[ Obituary Status: ]----------------------------------------------------------" >>$report 
  $ndsbin/ndsrepair --config-file $ndsconf -C -Ad -A | awk 'NR > 12' >>$report
else
  echo "eDirectory and it's related services are not installed on this server" >>$report
fi
addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]---------------------------" >>$report
addspace

# e-mail report
mail -s "$host OES Health Report" -a $report $email < /root/bin/oes-healthmsg.txt

# Finished
exit 1

