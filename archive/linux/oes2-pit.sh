#!/bin/bash
REL=0.01-05
##############################################################################
#
#    oes2-pit.sh - OES2 SP3 Post Installation Tuning script
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
# Last updated: Mon Nov 26 10:06:57 2012 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog.
DIALOG=${DIALOG=dialog}

IP1=/tmp/ip1.tmp.$$
IP2=/tmp/ip2.tmp.$$
IP3=/tmp/ip3.tmp.$$
P4=/tmp/p4.tmp.$$

function show_gpl3(){
$DIALOG --msgbox "oes-tune.sh  Copyright (C) 2012  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0
}

# Opening note about the script
$DIALOG --help-button --help-label "gpl 3" --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "V$REL OES2 Post Installation Tuning Script" \
		 --msgbox "This script will automatically apply the recommended post installation configuration to your server. During the question phase you can use ctrl+c, ESC, or the cancel button to exit this script. Once the questions have been answered the script will perform the changes to the server." 0 0

case $? in
	2)
		show_gpl3;;
esac

# Question 1 - Server IP Address for LUM?
$DIALOG --colors --title "\Zb\Z0This Server's IP Address" --clear \
		 --backtitle "V$REL OES2 Post Installation Tuning Script" \
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
		 --backtitle "V$REL OES2 Post Installation Tuning Script" \
		 --msgbox "The LUM alternate LDAP server list is used when the preferred server is not responding.\nAlternate servers should be on the same LAN segment, and not accross WAN links." 0 0

# Question 2 - First IP Address of Alternate-ldap server for LUM?
$DIALOG --colors --title "\Zb\Z0IP Address of a first alternate OES server" --clear \
		 --backtitle "V$REL OES2 Post Installation Tuning Script" \
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

# Question 3 - Second IP Address of Alternate-ldap server for LUM?
$DIALOG --colors --title "\Zb\Z0IP Address of a second alternate OES server" --clear \
		 --backtitle "V$REL OES2 Post Installation Tuning Script" \
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
clear

# Question 4 - High port number for SSH?
$DIALOG --colors --title "\Zb\Z0Alternative high port number for SSH" --clear \
		 --backtitle "V$REL OES2 Post Installation Tuning Script" \
		 --inputbox "Please enter the desired high port number for SSH configuration, or 22 for the default:" 0 0 2> $P4

SSHPRT=$?

case $SSHPRT in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $P4 ; then
			cat $P4
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac
clear

# NSS Settings for Mail
echo "Updating NSS configuration"

echo -e "/noatime=mail" > /dev/nsscmd
echo -e "/nosalvage=mail" > /dev/nsscmd
echo "/IDCacheSize=131072" >> /etc/opt/novell/nss/nssstart.cfg

echo "NSS configuration complete."
sleep 5

# SSH Configuration
echo "Updating SSH configuration"
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Port $SSHPRT" >> /etc/ssh/sshd_config

rcsshd restart
echo "SSH configuration complete."
sleep 5

# LUM Configuration
echo "Updating LUM/NAMCD configuration"
namconfig set preferred-server=$retval1
namconfig set alternative-ldap-server-list=$retval2,$retval3
namconfig set persistent-search=no
namconfig set persistent-cache-refresh-period=3600
namconfig set log-file-location=/var/log/
namconfig set log-level=3

rcnamcd restart
sleep 2
ADM=$(namconfig get | grep admin-fdn | cut -f 2- -d "=")
echo "You will need the password of the user listed in namconfig, which is: $ADM"
namconfig -k
namconfig cache_refresh

echo "LUM configuration is complete."
sleep 5

# NCP Configuration
echo "Updating NCP configuration"
ncpcon set CROSS_PROTOCOL_LOCKS=1
ncpcon set FIRST_WATCHDOG_PACKET=5
ncpcon set CONCURRENT_ASYNC_REQUESTS=75
ncpcon set MAXIMUM_CACHED_FILES_PER_SUBDIRECTORY=6000
ncpcon set MAXIMUM_CACHED_FILES_PER_VOLUME=120000
ncpcon set MAXIMUM_CACHED_SUBDIRECTORIES_PER_VOLUME=300000

/etc/init.d/ncp2nss restart
echo "NCP configuration is complete."
sleep 5

# NDS Configuration
echo "Updating NDS configuration"
echo "NDSD_TRY_NMASLOGIN_FIRST=true" >> /opt/novell/eDirectory/sbin/pre_ndsd_start
echo "export NDSD_TRY_NMASLOGIN_FIRST" >> /opt/novell/eDirectory/sbin/pre_ndsd_start
echo "nmas LoginInfo 1" >> /var/opt/novell/eDirectory/data/nmas.config
echo "nmas RefreshRate 300" >> /var/opt/novell/eDirectory/data/nmas.config
ndsconfig set n4u.nds.advertise-life-time=1800
ndsconfig set n4u.server.max-threads=256

rcndsd restart
echo "NDS configuration is complete."
sleep 5

# TCP Configuration
echo "Updating TCP configuration"
echo 600 > /proc/sys/net/ipv4/tcp_keepalive_time
echo 60 > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo 20 > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "net.ipv4.tcp_keepalive_time = 600" >> /etc/sysctl.conf
echo "net/ipv4.tcp_keepalive_intvl = 60" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_probes = 20" >> /etc/sysctl.conf

echo "TCP configuration is complete."
sleep 5

# UDEV Configuration
echo "Updating UDEV configuration"
MEM=$(cat /proc/meminfo | grep MemTotal | cut -f 8 -d " ")
MEMG=$(echo "scale=3; $MEM/1000000" | bc)
UDEVNEWVAL=$(echo "(128 +(125 * $MEMG)) * 2" | bc | cut -f 1 -d ".")
UDEV1=$(cat /etc/sysconfig/udev | grep -w UDEVD_MAX_CHILDS | cut -f 2 -d "=")
UDEV2=$(cat /etc/sysconfig/udev | grep -w UDEVD_MAX_CHILDS_RUNNING | cut -f 2 -d "=")

echo "The current udev value for max childs is: $UDEV1"
echo "The current udev value for max childs running is: $UDEV2"
echo "The new value for both will be: $UDEVNEWVAL"

sed -i "s/UDEVD_MAX_CHILDS=$UDEV1/UDEVD_MAX_CHILDS=$UDEVNEWVAL/" /etc/sysconfig/udev
sed -i "s/UDEVD_MAX_CHILDS_RUNNING=$UDEV2/UDEVD_MAX_CHILDS_RUNNING=$UDEVNEWVAL/" /etc/sysconfig/udev

echo "UDEV configuration is complete."

clear

# Clean up unneeded files
rm -f $IP1
rm -f $IP2
rm -f $IP3
clear
echo "========================================================================"
echo "V$REL RCMP Post Installation script"
echo "All required tuning parameters have been applied to this server." 
echo "To ensure all changes take effect please reboot the server at your"
echo "earliest convenience." 
echo "RCMP ECS Team"
echo "------------------------------------------------------------------------"

exit

