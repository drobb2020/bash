#!/bin/bash
REL=0.01-15
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
# Date Created: Tue Mar 22 11:53:52 EDT 2011
# Last updated: Tue Feb 05 15:29:39 2013 
# Suggested crontab command: * 7 * * 1,3,5 /root/bin/oes2health.sh
# Supporting file: /root/bin/OES2-healthmsg.txt
# Additional Notes: Don't forget to set your custom variables for your environment.
##############################################################################
# Declare varilables
TODAY=$(date +"%d-%m-%Y")
HOST=$(hostname)
LIST=$(chkconfig --list | grep 5:on | cut -f-1 -d" "|tr -t "\012" "\040")

# Custom Variables
REPDIR=/root/reports
REPNAME=OES2_Health_Report
NDSCFG=/etc/opt/novell/eDirectory/conf/nds.conf
NDSBIN=/opt/novell/eDirectory/bin
EMAIL=edirreports@excession.org
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
echo "--[ SLES & OES2 Health Report v${REL} ]------------------------------------" >>$REPORT
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
echo "IP Address: $(cat /etc/hosts | grep excs2 | awk '{print $1F}')" >>$REPORT
echo "Hostname: $(hostname -f)" >>$REPORT
addspace

# Report SLES uptime statistics
echo "--[ Server Uptime: ]--------------------------------------------------------" >>$REPORT
uptime >>$REPORT
addspace

# Report Memory usage
echo "--[ Memory Usage: ]---------------------------------------------------------" >>$REPORT
free -m >>$REPORT
addspace

# Report disk space usage
echo "--[ File System Space Usage: ]----------------------------------------------" >>$REPORT
df -h >>$REPORT
addspace

# Report on daemons
echo "--[ Critical Daemon Status: ]-----------------------------------------------" >>$REPORT
echo "apache web server is $(service apache2 status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "cron is $(service cron status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Linux User Management is $(service namcd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "NCP 2 NSS is $(service ncp2nss status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "CIFS is $(service novell-cifs status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Novell web server (httpstk) is $(service novell-httpstkd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Novell Backup Agent is $(service novell-smdrd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Tomcat 5 is $(service novell-tomcat5 status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "ZENworks Management is $(service novell-zmd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Name service cache is $(service nscd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Network Time Protcol (ntp) is $(service ntp status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Service Location Protcol is $(service slpd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "Secure Shell is $(service sshd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
addspace

# Report OES2 eDirectory status
if [ -e $NDSCFG ]
		then
		echo "--[ NCP Connections ]-------------------------------------------------------" >>$REPORT
		/sbin/ncpcon "connections" 2>/dev/null 1>>$REPORT
		addspace
		echo "--[ NCP Statistics ]--------------------------------------------------------" >>$REPORT
		/sbin/ncpcon "stats" 2>/dev/null 1>>$REPORT
		addspace
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
		echo "--[ Obituary Status: ]------------------------------------------------------" >>$REPORT 
		$NDSBIN/ndsrepair --config-file $NDSCFG -C -Ad -A | awk 'NR > 12' >>$REPORT
		addspace
		else
		addspace
		echo "--[ eDirectory is not installed on this server ]----------------------------" >>$REPORT
		addspace
fi
# Report footer
echo "--[ Report finished ]-------------------------------------------------------" >>$REPORT

# e-mail report
mail -s "$HOST SLES and OES2 Health Report" -a $REPORT $EMAIL < $INCDIR/OES2-healthmsg.txt

# Finished
exit

