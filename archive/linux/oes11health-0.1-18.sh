#!/bin/bash
REL=0.1-18
##############################################################################
#
#    oes11health.sh - Create an automated health report for OES11 Linux servers
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
# Last updated: Mon Jul 29 12:26:13 2013 
# Suggested Crontab command: * 7 * * 1,3,5 /root/bin/oes11health.sh
# Supporting file: /root/bin/OES11-healthmsg.txt
# Additional notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare varilables
TODAY=$(date +"%d-%m-%Y")
HOST=$(hostname)
LIST=$(chkconfig --list | grep 5:on | cut -f-1 -d" "|tr -t "\012" "\040")

# Custom Variables
REPDIR=/root/reports
REPNAME=OES11_Health_Report
NDSCFG=/etc/opt/novell/eDirectory/conf/nds.conf
NDSBIN=/opt/novell/eDirectory/bin
OSVER=$(cat /etc/SuSE-release | grep VERSION | cut -f 2 -d "=" | sed -e 's/^[ \t]*//')
RL=$(/sbin/runlevel | cut -f 2 -d " ")
EMAIL=root
HT=$HOST-$TODAY
REPORT=$REPDIR/$REPNAME-from-$HT.txt

# Functions
addspace() { echo "" >>$REPORT 
}

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
echo "--[ SLES 11 & OES 11 Health Report v${REL} ]-----------------------------------" >> $REPORT
echo "--[ Report started at: $(date +'%a, %b, %d, %Y %k:%M:%S') ]----------------------------" >> $REPORT
addspace

# Report SLES version
echo "--[ SLES Version: ]-------------------------------------------------------------" >> $REPORT
cat /etc/SuSE-release >> $REPORT
addspace

# Linux Kernel version
echo "--[ Kernel Version: ]-----------------------------------------------------------" >> $REPORT
echo "Kernel: $(uname -r)" >> $REPORT
echo "Architecture: $(uname -i)" >>$REPORT
addspace

# IP Address and Hostname
echo "--[ IP Address and Hostname of server: ]----------------------------------------" >>$REPORT
echo "IP Address: $(cat /etc/hosts | grep $HOST | awk '{print $1F}')" >>$REPORT
echo "Hostname: $(hostname -f)" >>$REPORT
addspace

# Report SLES uptime statistics
echo "--[ Server Uptime: ]------------------------------------------------------------" >>$REPORT
uptime >>$REPORT
addspace

# Report Memory usage in Megabytes
echo "--[ Memory Usage: ]-------------------------------------------------------------" >>$REPORT
free -mot >>$REPORT
addspace

# Report Virtual memory statistics
echo "--[ Virtual Memory Statistics: ]------------------------------------------------" >>$REPORT
vmstat 2 4 >>$REPORT
addspace

# Report disk space usage
echo "--[ File System Space Usage: ]--------------------------------------------------" >>$REPORT
df -lh >>$REPORT
addspace

# Report inode usage
echo "--[ Inode usage on Linux file systems: ]----------------------------------------" >>$REPORT
df -i | awk 'NR>1{exit};1' >>$REPORT
df -i | sed -n '/dev\/sd/p' >>$REPORT
addspace

# Report on daemons
echo "--[ Critical Daemon Status for SLES11 Services: ]-------------------------------" >>$REPORT
APACHE2=$(ps -ef | grep -v grep | grep -cw httpd)
# apache web server
if [ $APACHE2 -ge 1 ]
	then
	echo "Apache Web Server is running" >> $REPORT
	else
	echo "Apache Web Server appears to be dead or intentionally stopped, please investigate." >>$REPORT
fi
# cron daemon
CRON=$(ps -ef | grep -v grep | grep -cw cron)
if [ $CRON -ge 1 ]
	then
	echo "Cron daemon is running" >>$REPORT
	else
	echo "Cron appears to be dead or intentionally stopped, please investigate." >>$REPORT
fi
# Network Time Protcol (ntp)
NTP=$(ps -ef | grep -v grep | grep -cw ntpd)
if [ $NTP -ge 1 ]
	then
	echo "Network Time Protocol (ntp) is running" >>$REPORT
	else
	echo "Network Time Protocol (ntp) appears to be dead or intentionally stopped, please investigate." >>$REPORT
fi
# Service Location Protcol (slp)
SLP=$(ps -ef | grep -v grep | grep -cw slpd)
if [ $SLP -ge 1 ]
	then
	echo "Service Location Protocol (slp) is running" >>$REPORT
	else
	echo "Service Location Protocol (slp) appears to be dead or intentionally stopped, please investigate." >>$REPORT
fi
# Secure Shell (ssh)
SSH=$(ps -ef | grep -v grep | grep -cw sshd)
if [ $SSH -ge 1 ]
	then
	echo "Secure Shell Daemon (sshd) is running" >>$REPORT
	else
	echo "Secure Shell Daemon (sshd) appears to be dead or intentionally stopped, please investigate." >>$REPORT
fi
# OWCIMOMD or SFCB Daemons
if [ $OSVER -eq 10 ]
    then
	CIMOM=$(ps -ef | grep -v grep | grep -cw owcimomd)
	if [ $CIMOM -ge 1 ]
	    then
		echo "Open Web CIMON Daemon (owcimond) is running" >> $REPORT
	    else
		echo "Open Web CIMOM Daemon (owcimond) appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
    else
	SFCB=$(ps -ef | grep -v grep | grep -cw sfcbd)
	if [ $SFCB -ge 1 ]
	    then
		echo "Small Footprint CIM Broker (sfcb) is running" >>$REPORT
	    else
		echo "Small Footprint CIM Broker (sfcb) appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
fi
# Name service cache
NSCD=$(ps -ef | grep -v grep | grep -cw nscd)
if [ $NSCD -ge 1 ]
    then
	echo "Name Service Cache Daemon is running" >>$REPORT
    else
	echo "Name Service Cache Daemon appears to be dead or intentionally stopped, please investigate." >>$REPORT
fi
# pure-ftpd daemon
SNRFTP=$(/sbin/chkconfig -l pure-ftpd | grep $RL:on | cut -f 24 -d " ")
if [ -z $SNRFTP ]
    then
	echo "pure-ftpd is installed but not configured to run." >> $REPORT
    else
	PFTPD=$(ps -ef | grep -v grep | grep -cw pure-ftpd)
	    if [ $PFTPD -ge 1 ]
		then
		    echo "pure-ftpd service is running" >>$REPORT
		else
		    echo "pure-ftpd service appears to be dead or intentionally stopped, please investigate." >>$REPORT
	    fi
fi
addspace

echo "--[ Critical Daemon Status for OES11 Services: ]--------------------------------" >>$REPORT
# eDirectory (ndsd)
if [ -e $NDSCFG ]
	then
	NDSD=$(ps -ef | grep -v grep | grep -cw ndsd)
	if [ $NDSD -ge 1 ]
		then
		echo "eDirectory daemon is running" >>$REPORT
		else
		echo "eDirectory daemon appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
# Linux User Management
	LUM=$(ps -ef | grep -v grep | grep -cw namcd)
	if [ $LUM -ge 1 ]
		then
		echo "Linux User Management is running" >>$REPORT
		else
		echo "Linux User Management appears to be dead or intentionally stopped, please investigate" >>$REPORT
	fi
# NCP2NSS
	N2N=$(ps -ef | grep -v grep | grep -cw ncp2nss)
	if [ $N2N -ge 1 ]
		then
		echo "The eDir to NSS connector (ncp2nss) is running" >>$REPORT
		else
		echo "The eDir to NSS connector (ncp2nss appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
# NDPAPP
	NDPAPP=$(ps -ef | grep -v grep | grep -cw ndpapp)
	if [ $NDPAPP -ge 1 ]
		then
		echo "The LUM to NSS connector (ndpapp) is running" >>$REPORT
		else
		echo "The LUM to NSS connector (ndpapp) appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
# CIFS
	CIFS=$(ps -ef | grep -v grep | grep -cw cifsd)
	if [ $CIFS -ge 1 ]
		then
		echo "Novell CIFS is running" >>$REPORT
		else
		echo "Novell CIFS appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
# Novell web server (httpstk)
	HTTPSTK=$(ps -ef | grep -v grep | grep -cw httpstkd)
	if [ $HTTPSTK -ge 1 ]
		then
		echo "Novell Web Server is running" >>$REPORT
		else
		echo "Novell Web Server appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
# Novell Backup Agent (smdrd) 
	SMDRD=$(ps -ef | grep -v grep | grep -cw smdrd)
	if [ $SMDRD -ge 1 ]
		then
		echo "Novell Backup Agent (smdrd) is running" >>$REPORT
		else
		echo "Novell Backup Agent (smdrd) appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
# Novell Tomcat5 or 6
	if [ $OSVER -eq 10 ]
    	    then
		TC5=$(ps -ef | grep -v grep | grep -cw tomcat5)
		if [ $TC5 -ge 1 ]
	      	    then
			echo "Novell Tomcat5 is running" >>$REPORT
	    	    else
			echo "Novell Tomcat5 appears to be dead or intentionally stopped, please investigate." >>$REPORT
		fi
    	else
		TC6=$(ps -ef | grep -v grep | grep -cw tomcat6)
		if [ $TC6 -ge 1 ]
		    then
			echo "Novell Tomcat6 is running" >>$REPORT
		    else
			echo "Novell Tomcat6 appears to be dead or intentionally stopped, please investigate." >>$REPORT
		fi
	fi
	else
	echo "eDirectory and it's related services are not installed on this server." >>$REPORT
fi
# GroupWise Agents
if [ -e /etc/init.d/grpwise ] 
	then
	DVA=$(ps -ef | grep -v grep | grep -cw 'gwdva')
	POA=$(ps -ef | grep -v grep | grep -cw 'gwpoa')
	MTA=$(ps -ef | grep -v grep | grep -cw 'gwmta')
	GWIA=$(ps -ef | grep -v grep | grep -cw 'gwia')
	if [ $DVA -ge 1 ]
		then
		echo "GroupWise Document Viewer Agent is running" >>$REPORT
		else
		echo "GroupWise Document Viewer Agent appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
	if [ $POA -ge 1 ]
		then
		echo "GroupWise Post Office Agent is running" >>$REPORT
		else
		echo "GroupWise Post Office Agent appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
	if [ $MTA -ge 1 ]
		then
		echo "GroupWise Message Transfer Agent is running" >>$REPORT
		else
		echo "GroupWise Message Transfer Agent appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
	if [ $GWIA -ge 1 ]
		then
		echo "GroupWise Internet Agent is running" >>$REPORT
		else
		echo "GroupWise Internet Agent appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
	else
	echo "GroupWise is not installed on this server." > /dev/null
fi
# GroupWise Monitor
if [ -e /etc/init.d/grpwise-ma ]
	then
	GWMA=$(ps -ef | grep -v grep | grep -cw gwmon)
	if [ $GWMA -ge 1 ]
		then
		echo "GroupWise Monitor Agent is running" >>$REPORT
		else
		echo "GroupWise Monitor Agent appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
	else
	echo "GroupWise Monitor is not installed on this server" > /dev/null
fi
# Novell Messenger
if [ -e /etc/init.d/novell-nmma ]
	then
	MA=$(ps -ef | grep -v grep | grep -cw nmma)
	if [ $MA -ge 1 ]
		then
		echo "Novell Messenger Agent is running" >>$REPORT
		else
		echo "Novell Messenger Agent appears to be dead or intentionally stopped, please investigate." >>$REPORT
	fi
	else
	echo "Novell Messenger is not installed on this server" > /dev/null
fi
if [ -e /etc/init.d/novell-nmaa ]
	then
	AA=$(ps -ef | grep -v grep | grep -cw nmaa)
	if [ $AA -ge 1 ]
		then
		echo "Novell Messenger Archive Agent is running" >>$REPORT
		else
		echo "Novell Messenger Archive Agent appears to be dead or intentionally shutdown, please investigate." >>REPORT
	fi
	else
	echo "Novell Messenger Archive is not installed on this server" > /dev/null
fi
addspace

# Report OES11 eDirectory status
if [ -e $NDSCFG ]
	then
	echo "--[ OES 11 Version: ]-----------------------------------------------------------" >>$REPORT 
	cat /etc/novell-release >>$REPORT
	addspace
	sleep 5
	echo "--[ NCP Connections ]-----------------------------------------------------------" >>$REPORT
	/sbin/ncpcon "connections" 2>/dev/null 1>>$REPORT
	addspace
	echo "--[ NCP Statistics ]------------------------------------------------------------" >>$REPORT
	/sbin/ncpcon "stats" 2>/dev/null 1>>$REPORT
	addspace
	echo "--[ NCP Thread Usage ]----------------------------------------------------------" >>$REPORT
	/sbin/ncpcon threads 2>/dev/null 1>>$REPORT
	addspace
	sleep 5
	echo "--[ NDS Thread Pool ]-----------------------------------------------------------" >>$REPORT
	/opt/novell/eDirectory/bin/ndstrace -c threads | awk 'NR < 7' >>$REPORT
	addspace
	sleep 10
	echo "--[ Current NDS Status: ]-------------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsstat -s | awk 'NR > 7' >>$REPORT
	addspace
	sleep 10
	echo "--[ Timesync Status: ]----------------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsrepair --config-file $NDSCFG -T | awk 'NR > 16' >>$REPORT
	addspace
	sleep 10
	echo "--[ Replica Sync Status: ]------------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsrepair --config-file $NDSCFG -E | awk 'NR > 10' >>$REPORT
	addspace
	sleep 10
	echo "--[ Obituary Status: ]----------------------------------------------------------" >>$REPORT 
	$NDSBIN/ndsrepair --config-file $NDSCFG -C -Ad -A | awk 'NR > 12' >>$REPORT
	else
	addspace
	echo "eDirectory and it's related services are not installed on this server" >>$REPORT
	addspace
fi
addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]---------------------------" >>$REPORT
addspace

# e-mail report
mail -s "$HOST OES11 Health Report" -a $REPORT $EMAIL < /root/bin/oes11-healthmsg.txt

# Finished
exit

