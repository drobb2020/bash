#!/bin/bash
REL=0.1-08
##############################################################################
#
#    oes-rcmp-pit-lrs.sh - RCMP Post Installation script for local new server
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
# Date Created: Fri Nov 09 09:55:42 2012
# Last updated: Wed Jun 05 08:39:40 2013 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog.
DIALOG=${DIALOG=dialog}

IP1=/tmp/ip1.tmp.$$
IP2=/tmp/ip2.tmp.$$
IP3=/tmp/ip3.tmp.$$
SL=/tmp/sl.tmp.$$
SC=/tmp/sc.tmp.$$

function show_gpl3(){
$DIALOG --msgbox "oes-rcmp-pit-lns.sh  Copyright (C) 2013  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0
}

# Opening note about the script
$DIALOG --help-button --help-label "gpl 3" --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --msgbox "This script will automatically apply the recommended post installation configuration to your server. During the question phase you can use ctrl+c, ESC, or the cancel button to exit this script. Once the questions have been answered the script will perform the changes to the server." 0 0

case $? in
	2)
		show_gpl3;;
esac

# Question 1 - Server IP Address for LUM
$DIALOG --colors --title "\Zb\Z0This Server's IP Address" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --inputbox "Please enter the IP Address of this server for LUM configuration:" 0 0 2> $IP1

retval1=$?

case $retval1 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $IP1 ; then
			cat $IP1
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac


$DIALOG --colors --title "\Zb\Z0LUM alternate-ldap-server-list rule" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --msgbox "The LUM alternate LDAP server list is used when the preferred server is not responding.\nAlternate servers should be on the same LAN segment, and not accross WAN links." 0 0

# Question 2 - First IP Address of Alternate-ldap server for LUM
$DIALOG --colors --title "\Zb\Z0IP Address of a first alternate OES server" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --inputbox "Please enter the IP Address of the first alternate LDAP server for LUM configuration:" 0 0 2> $IP2

retval2=$?

case $retval2 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $IP2 ; then
			cat $IP2
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac

# Question 3 - Second IP Address of Alternate-ldap server for LUM
$DIALOG --colors --title "\Zb\Z0IP Address of a second alternate OES server" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --inputbox "Please enter the IP Address of the second alternate LDAP server for LUM configuration:" 0 0 2> $IP3

retval3=$?

case $retval3 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $IP3 ; then
			cat $IP3
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac

# Question 4 - System Location Information for snmp config
$DIALOG --colors --title "\Zb\Z0System Location for SNMP" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --inputbox "Please enter the location of the server:" 0 0 2> $SL

retval4=$?

case $retval4 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $SL ; then
			cat $SL
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac

# Question 5 - System Contact information for snmp config
$DIALOG --colors --title "\Zb\Z0System Contact for SNMP" --clear \
		 --backtitle "v$REL RCMP Post Installation script" \
		 --inputbox "Please enter the primary contact information for this server:" 0 0 2> $SC

retval5=$?

case $retval5 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $SC ; then
			cat $SC
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac
clear

# NSS Settings for Mail
echo "Turning off access time and salvage on the MAIL volume."

echo -e "/noatime=mail" > /dev/nsscmd
echo -e "/nosalvage=mail" > /dev/nsscmd

sleep 2
clear

# Configure SSH to DSB specs
echo "Changing SSH configuration"
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Port 3479" >> /etc/ssh/sshd_config
# restart ssh daemon for change to take effect
rcsshd restart
echo "SSH is now running on port 3479, and the root no longer has SSH access."
sleep 2
clear

# LUM Configuration
echo "Changing LUM configuration"
namconfig set preferred-server=$(cat /tmp/ip1.tmp.$$)
namconfig set alternative-ldap-server-list=$(cat /tmp/ip2.tmp.$$),$(cat /tmp/ip3.tmp.$$)
namconfig set persistent-search=no

sleep 2

namconfig -k
echo "LUM configuration is complete."
sleep 2
clear

# SNMP Configuration
echo "Changing SNMP configuration"
echo -e rwcommunity no 127.0.0.1 >> /etc/snmp/snmpd.conf
/etc/init.d/snmpd restart
sleep 2
/usr/bin/snmpset -c no -v 1 localhost system.sysContact.0 s "$(cat /tmp/sc.tmp.$$)"
/usr/bin/snmpset -c no -v 1 localhost system.sysLocation.0 s "$(cat /tmp/sl.tmp.$$)"
SC1=$(cat /etc/snmp/snmpd.conf | grep -v "#" | grep -w syscontact)
SL1=$(cat /etc/snmp/snmpd.conf | grep -v "#" | grep -w syslocation)
sed -i "s/$SC1/syscontact $(cat /tmp/sc.tmp.$$)/" /etc/snmp/snmpd.conf
sed -i "s/$SL1/syslocation $(cat /tmp/sl.tmp.$$)/" /etc/snmp/snmpd.conf
echo "SNMP configuration is complete."
sleep 2
clear

# NDS Configuration
echo "Changing eDirectory configuration"
ndsconfig set n4u.nds.advertise-life-time=600
ndsconfig set n4u.server.max-threads=256

rcndsd restart
echo "NDS configuration is complete."
sleep 1
clear

# Clean up unneeded files
rm -f $IP1
rm -f $IP2
rm -f $IP3
rm -f $SL
rm -f $SC
clear

echo "========================================================================"
echo "v$REL SSC Post Installation script"
echo "All required tuning parameters have been applied to this server." 
echo "To ensure all changes take effect please reboot the server at your"
echo "earliest convenience." 
echo "SSC ECS Team"
echo "------------------------------------------------------------------------"

exit

