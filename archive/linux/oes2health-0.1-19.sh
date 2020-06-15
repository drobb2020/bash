#!/bin/bash
REL=0.1-19
##############################################################################
#
#    oes2health.sh - Create an automated health report for OES2 Linux servers
#    Copyright (C) 2012  David Robb
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#
##############################################################################
# Date Created: Tue Mar 22 11:53:52 2011
# Last updated: Thu Feb 07 14:40:27 2013 
# Suggested crontab command: * 7 * * 1,3,5 /root/bin/oes2health.sh #for weekly execution
#                            * * 2 * * /root/bin/oes2health-0.1.19.sh #for monthly execution
# Supporting file: /root/bin/oes2-healthmsg.txt
# Additional Notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare varilables
TODAY=$(date +"%d-%m-%Y")
HOST=$(hostname)
LIST=$(chkconfig --list | grep 5:on | cut -f-1 -d" "|tr -t "\012" "\040")
ID=$(whoami)

# Custom Variables
REPDIR=/root/reports
REPNAME=OES2_Health_Report
NDSCFG=/etc/opt/novell/eDirectory/conf/nds.conf
NDSBIN=/opt/novell/eDirectory/bin
NSSSBIN=/opt/novell/nss/sbin
OESCFG=/etc/sysconfig/novell
EMAIL=root
HT=$HOST-$TODAY
REPORT=$REPDIR/$REPNAME-$HT.txt
INCDIR=/root/bin

# Functions
addspace() { echo "" >>$REPORT 
}

# Check if user is root
if [ $ID != "root" ]
    then
	echo "You must be root to run this script. Exiting..."
	exit
fi

# Create report directory if it doesn't exist
if [ ! -e $REPDIR ] 
    then
	/bin/mkdir $REPDIR
fi

# Delete old report
if [ -e $REPDIR/$REPNAME*.txt ]
		then
		/bin/rm $REPDIR/$REPNAME*.txt
fi

# Delete old ndsrepair.log
if [ -e $NDSCFG ]
		then
		/bin/rm /var/opt/novell/eDirectory/log/ndsrepair.log
fi

# Create new report and set date timestamp
addspace
echo "--[ SLES10 & OES2 Health Report v${REL} ]----------------------------------" >>$REPORT
addspace
echo "Report Date and Time: $(date)" >>$REPORT
addspace

# Report SLES version
echo "--[ SLES Version ]----------------------------------------------------------" >>$REPORT
echo "SLES Release: $(cat /etc/SuSE-release | grep SUSE | cut -d'(' -f1)" >>$REPORT
echo "Service Pack: $(cat /etc/SuSE-release | grep PATCHLEVEL | awk '{print $3}')" >>$REPORT
addspace

# Report OES2 version
if [ -e /etc/novell-release ] 
	then
	echo "--[ OES2 Version ]----------------------------------------------------------" >>$REPORT
	echo "OES2 Release: $(cat /etc/novell-release | grep Novell | cut -d'(' -f1)" >>$REPORT
	echo "Service Pack: $(cat /etc/novell-release | grep PATCHLEVEL | awk '{print $3}')" >>$REPORT
	addspace
fi

# Linux Kernel version
echo "--[ Kernel Version: ]-------------------------------------------------------" >>$REPORT
echo "Kernel: $(uname -r)" >>$REPORT
echo "Architecture: $(uname -i)" >>$REPORT
addspace

# IP Address and Hostname
echo "--[ IP Address and Hostname of server: ]------------------------------------" >>$REPORT
echo "IP Address: $(cat /etc/hosts | grep $HOST | awk '{print $1F}')" >>$REPORT
echo "Hostname: $(hostname -f)" >>$REPORT
addspace

# Report SLES uptime statistics
echo "--[ Server Uptime: ]--------------------------------------------------------" >>$REPORT
/usr/bin/uptime >>$REPORT
addspace

# Report Memory usage
echo "--[ Memory Usage: ]---------------------------------------------------------" >>$REPORT
/usr/bin/free -mot >>$REPORT
addspace

# Report Virtual Memory Statistics
echo "--[ Virtual Memory Statistics: ]--------------------------------------------" >>$REPORT
/usr/bin/vmstat 2 4 >>$REPORT
addspace

# Report disk space usage
echo "--[ File System Space Usage: ]----------------------------------------------" >>$REPORT
/bin/df -h >>$REPORT
addspace

# Report inode usage
echo "--[ Inode usage on Linux FS: ]----------------------------------------------" >>$REPORT
df -i | awk 'NR>1{exit};1' >>$REPORT
df -i | sed -n '/dev\/sda/p' >>$REPORT
addspace

# Report on SLES 10 daemons
echo "--[ Critical Daemon Status for SLES10 Services: ]---------------------------" >>$REPORT
APACHE2=$(ps -ef | grep -v grep | grep -cw httpd)
if [ $APACHE2 -ge 1 ]
    then
	echo "apache web server is running" >>$REPORT
    else
	echo "apache web server appears to be dead or intentionally stopped, please investigate" >>$REPORT
fi
CRON=$(ps -ef | grep -v grep | grep -cw cron)
if [ $CRON -ge 1 ]
    then
	echo "cron daemon is running" >>$REPORT
    else
	echo "cron appears to be dead or intentionally stopped, please investigate" >>$REPORT
fi
NTP=$(ps -ef | grep -v grep | grep -cw ntpd)
if [ $NTP -ge 1 ]
    then
	echo "Network Time Protcol (ntp) is running" >>$REPORT
    else
	echo "NTP appears to be dead or intentionally stopped, please investigate" >>$REPORT
fi
SLP=$(ps -ef | grep -v grep | grep -cw slpd)
if [ $SLP -ge 1 ]
    then
	echo "Service Location Protcol is running" >>$REPORT
    else
	echo "SLP appears to be dead or intentionally stopped, please investigate" >>$REPORT
fi
SSH=$(ps -ef | grep -v grep | grep -cw sshd)
if [ $SSH -ge 1 ]
    then
	echo "Secure Shell is running" >>$REPORT
    else
	echo "sshd appears to be dead or intentionally stopped, please investigate" >>$REPORT
fi
NSCD=$(ps -ef | grep -v grep | grep -cw nscd)
if [ $NSCD -ge 1 ]
    then
	echo "Name service cache is running" >>$REPORT
    else
	echo "cron appears to be dead or intentionally stopped, please investigate" >>$REPORT
fi
addspace

# Report on OES2 Daemons
echo "--[ Critical Daemon Status for OES2 Services: ]-----------------------------" >>$REPORT
if [ -e $OESCFG/oes-ldap ]
    then
	NDSD=$(ps -ef | grep -v grep | grep -cw ndsd)
	if [ $NDSD -ge 1 ]
	    then
		echo "Novell Directory Services Daemon is running" >> $REPORT
	    else
		echo "" >>$REPORT
	fi
	LUM=$(ps -ef | grep -v grep | grep -cw namcd)
	if [ $LUM -ge 1 ]
	    then
		echo "Linux User Management is running" >>$REPORT
	    else
		echo "LUM (namcd) appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
	NCP2NSS=$(ps -ef | grep -v grep | grep -cw ncp2nss)
	if [ $NCP2NSS -ge 1 ]
	    then
		echo "NCP 2 NSS is $(service ncp2nss status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
	    else
		echo "ncp2nss appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
	# echo "CIFS is $(service novell-cifs status | awk '{print $NF}' | sed -e 's/\.//g')" 2>/dev/null >>$REPORT
	HTTPSTK=$(ps -ef | grep -v grep | grep -cw httpstkd)
	if [ $HTTPSTK -ge 1 ]
	    then
		echo "Novell web server (httpstk) is running" >>$REPORT
	    else
		echo "Novell small web server appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
	SMDRD=$(ps -ef | grep -v grep | grep -cw smdrd)
	if [ $SMDRD -ge 1 ]
	    then
		echo "Novell Backup Agent is running" >>$REPORT
	    else
		echo "Novell backup agent appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
	TC5=$(ps -ef | grep -v grep | grep -cw tomcat5)
	if [ $TC5 -ge 1 ]
	    then
		echo "Tomcat 5 is running" >>$REPORT
	    else
		echo "Tomcat5 appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
	ZMD=$(ps -ef | grep -v grep | grep -cw zmd)
	if [ $ZMD -ge 1 ]
	    then
		echo "ZENworks Management daemon is running" >>$REPORT
	    else
		echo "ZMD appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
	addspace
    else
	addspace
	echo "OES Services are not installed on this server" >>$REPORT
	addspace
fi

# Report OES2 eDirectory status
if [ -e $NDSCFG ]
    then
	echo "--[ NCP Connections ]-------------------------------------------------------" >>$REPORT
	/sbin/ncpcon "connections" 2>/dev/null 1>>$REPORT
	addspace
	echo "--[ NCP Statistics ]--------------------------------------------------------" >>$REPORT
	/sbin/ncpcon "stats" 2>/dev/null 1>>$REPORT

	echo "--[ NCP Thread usage ]------------------------------------------------------" >>$REPORT
	/sbin/ncpcon "threads" 2>/dev/null 1>>$REPORT
	addspace
	sleep 2
	echo "--[ NSS Space Information ]-------------------------------------------------" >>$REPORT
	echo -e 'c\nSpaceInformation\nC\n\nexit' | $NSSSBIN/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' >> $REPORT
	addspace
	sleep 2
	echo "--[ Current NDS Status: ]---------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsstat -s | awk 'NR > 8' >>$REPORT
	addspace
	sleep 10
	echo "--[ Timesync Status: ]------------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsrepair --config-file $NDSCFG -T | awk 'NR > 16' >>$REPORT
	addspace
	sleep 10
	echo "--[ Replica Sync Status: ]--------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsrepair --config-file $NDSCFG -E | awk 'NR > 10' >>$REPORT
	addspace
	sleep 10
	echo "--[ Replica State: ]--------------------------------------------------------" >>$REPORT
	echo | $NDSBIN/ndsrepair --config-file $NDSCFG -P 2>/dev/null | awk 'NR > 9' | sed -e "s/'//g" | sed -e 's/Press ENTER to continue... OR enter q to exit this listing //g' | sed '/^Enter/d' >>$REPORT
	addspace
	sleep 10
	echo "--[ Obituary Status: ]------------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsrepair --config-file $NDSCFG -C -Ad -A | awk 'NR > 12' >>$REPORT
	addspace
    else
	addspace
	echo "--[ eDirectory is not installed on this server ]----------------------------" >>$REPORT
	addspace
fi
# Report footer
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]-----------------------" >>$REPORT

# e-mail report
if [ -n "$EMAIL" ]
    then
	mail -s "$HOST SLES and OES2 Health Report" -a $REPORT $EMAIL < $INCDIR/oes2-healthmsg.txt
fi

# Finished
exit

