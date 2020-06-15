#!/bin/bash
REL=0.01-16
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
# Date Created: Tue Mar 22 11:53:52 EDT 2011
# Last updated: Fri Mar 23 16:02:00 EDT 2012
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
EMAIL=edirreports@excession.org
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
echo "--[ SLES 11 & OES 11 Health Report v${REL} ]-------------------------------" >> $REPORT
echo "--[ Report started at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]------------------------" >> $REPORT
addspace

# Report SLES version
echo "--[ SLES Version and Status: ]----------------------------------------------" >> $REPORT
cat /etc/SuSE-release >> $REPORT
addspace

# Linux Kernel version
echo "--[ Kernel Version: ]-------------------------------------------------------" >> $REPORT
echo "Kernel: $(uname -r)" >> $REPORT
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

# Report Memory usage in Megabytes
echo "--[ Memory Usage: ]---------------------------------------------------------" >>$REPORT
free -m >>$REPORT
addspace

# Report disk space usage
echo "--[ File System Space Usage: ]----------------------------------------------" >>$REPORT
df -h >>$REPORT
addspace

# Report on daemons
echo "--[ Critical Daemon Status: ]-----------------------------------------------" >>$REPORT
echo "apache web server is $(service apache2 status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "cron is $(service cron status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Linux User Management is $(service namcd status | awk '{print $NF}' | sed -e 's/\.//g')" >>$REPORT
echo "NCP 2 NSS is $(service ncp2nss status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "CIFS is $(service novell-cifs status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Novell web server (httpstk) is $(service novell-httpstkd status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Novell Backup Agent is $(service novell-smdrd status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Novell Tomcat6 is $(service novell-tomcat6 status | tail -n 1 | sed -e 's/\.//g')" >>$REPORT
echo "Name service cache is $(service nscd status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Network Time Protcol (ntp) is $(service ntp status | tail -n 1 | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Service Location Protcol is $(service slpd status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Secure Shell is $(service sshd status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
echo "Small Footprint CIM Broker is $(service sfcb status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
if [ -e /etc/init.d/grpwise ] 
	then
		echo "GroupWise DVA is $(service grpwise status gwdva | sed -e 's/\./\ /g' | awk '{ print $NF }')" >>$REPORT
		echo "GroupWise POA is $(service grpwise status excs2-po.excs2-do | sed -e 's/\./\ /g' | awk '{ print $NF }')" >>$REPORT
		echo "GroupWise MTA is $(service grpwise status excs2-do | sed -e 's/\./\ /g' | awk '{ print $NF }')" >>$REPORT
		echo "GroupWise Internet Agent is $(service grpwise status excs2gwia.excs2-do | sed -e 's/\./\ /g' | awk '{ print $NF }')" >>$REPORT
fi
if [ -e /etc/init.d/grpwise-ma ]
	then
		echo "GroupWise monitor agent is $(service grpwise-ma status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
fi
if [ -e /etc/init.d/novell-nmma ]
	then
		echo "Novell messenger agent is $(service novell-nmma status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
fi
if [ -e /etc/init.d/novell-nmaa ]
	then
		echo "Novell archive agent is $(service novell-nmaa status | awk '{ print $NF }' | sed -e 's/\.//g')" >>$REPORT
fi
addspace

# Report OES11 eDirectory status
if [ -e $NDSCFG ]
		then
		echo "--[ OES 11 Version: ]-------------------------------------------------------" >>$REPORT 
		cat /etc/novell-release >>$REPORT
		addspace
		sleep 5
		echo "--[ NCP Connections ]-------------------------------------------------------" >>$REPORT
		/sbin/ncpcon "connections" 2>/dev/null 1>>$REPORT
		addspace
		echo "--[ NCP Statistics ]--------------------------------------------------------" >>$REPORT
		/sbin/ncpcon "stats" 2>/dev/null 1>>$REPORT
		addspace
		echo "--[ NCP Thread Usage ]------------------------------------------------------" >>$REPORT
		/sbin/ncpcon threads 2>/dev/null 1>>$REPORT
		addspace
		sleep 5
		echo "--[ NDS Thread Pool ]-------------------------------------------------------" >>$REPORT
		/opt/novell/eDirectory/bin/ndstrace -c threads | awk 'NR < 7' >>$REPORT
		addspace
		sleep 10
		echo "--[ Current NDS Status: ]---------------------------------------------------" >>$REPORT 
		$NDSBIN/ndsstat -s | awk 'NR > 7' >>$REPORT
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
		else
		addspace
		echo "--[ eDirectory is not installed on this server ]----------------------------" >>$REPORT
		addspace
fi
addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]-----------------------" >>$REPORT
addspace

# e-mail report
# mail -s "$HOST OES11 Health Report" -a $REPORT $EMAIL < /root/bin/OES11-healthmsg.txt

# Finished
exit

