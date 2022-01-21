#!/bin/bash - 
#===============================================================================
#
#          FILE: oes-rcmp-pit.sh
# 
#         USAGE: ./oes-rcmp-pit.sh 
# 
#   DESCRIPTION: RCMP Post Installation script for OES2 SP2/SP3
#
#                Copyright (C) 2015  David Robb
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
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Nov 09 2012 09:55
#  LAST UPDATED: Thu Jul 23 2015 07:59
#      REVISION: 5
#     SCRIPT ID: 057
# SSC SCRIPT ID: ---
#===============================================================================
DIALOG=${DIALOG=dialog}                     # to run in an x windows (such as xming) change dialog to xdialog.
IP1=/tmp/ip1.tmp.$$                         # primary ip address for LUM
IP2=/tmp/ip2.tmp.$$                         # alternate ip address for LUM
IP3=/tmp/ip3.tmp.$$                         # alternate ip address for LUM

function show_gpl3(){
$DIALOG --msgbox "oes-tune.sh  Copyright (C) 2015  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0
}

# Opening note about the script
$DIALOG --help-button --help-label "gpl 3" --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "RCMP Post Installation script" \
		 --msgbox "This script will automatically apply the recommended post installation configuration to your server. During the question phase you can use ctrl+c, ESC, or the cancel button to exit this script. Once the questions have been answered the script will perform the changes to the server." 0 0

case $? in
	2)
		show_gpl3;;
esac

# Question 1 - Server IP Address for LUM?
$DIALOG --colors --title "\Zb\Z0This Server's IP Address" --clear \
		 --backtitle "RCMP Post Installation script" \
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
		 --backtitle "RCMP Post Installation script" \
		 --msgbox "The LUM alternate LDAP server list is used when the preferred server is not responding.\nAlternate servers should be on the same LAN segment, and not accross WAN links." 0 0

# Question 2 - First IP Address of Alternate-ldap server for LUM?
$DIALOG --colors --title "\Zb\Z0IP Address of a first alternate OES server" --clear \
		 --backtitle "RCMP Post Installation script" \
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
		 --backtitle "RCMP Post Installation script" \
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

# NSS Settings for Mail
echo "Turning off access time and salvage on the MAIL volume."

echo -e "/noatime=mail" > /dev/nsscmd
echo -e "/nosalvage=mail" > /dev/nsscmd

sleep 1
clear

# Configure SSH to DSB specs
echo "Changing SSH configuration"
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Port 3479" >> /etc/ssh/sshd_config
# restart ssh daemon for change to take effect
rcsshd restart
echo "SSH is now running on port 3479, and the root no longer has SSH access."
sleep 1
clear

# LUM Configuration
namconfig set preferred-server=$(cat /tmp/ip1.tmp.$$)
namconfig set alternative-ldap-server-list=$(cat /tmp/ip2.tmp.$$),$(cat /tmp/ip3.tmp.$$)
namconfig set persistent-search=no

rcnamcd restart
sleep 1

namconfig -k
echo "LUM configuration is complete."
sleep 1
clear

# NCP Configuration
ncpcon set CROSS_PROTOCOL_LOCKS=1
ncpcon set FIRST_WATCHDOG_PACKET=5
ncpcon set MAXIMUM_CACHED_FILES_PER_SUBDIRECTORY=10000
ncpcon set MAXIMUM_CACHED_FILES_PER_VOLUME=80000
ncpcon set MAXIMUM_CACHED_SUBDIRECTORIES_PER_VOLUME=200000

/etc/init.d/ncp2nss restart
echo "NCP configuration is complete."
sleep 1
clear

# NDS Configuration
ndsconfig set n4u.nds.advertise-life-time=600

rcndsd restart
echo "NDS configuration is complete."
sleep 1
clear

# Clean up unneeded files
rm -f $IP1
rm -f $IP2
rm -f $IP3
clear
echo "========================================================================"
echo "RCMP Post Installation script"
echo "All required tuning parameters have been applied to this server." 
echo "To ensure all changes take effect please reboot the server at your"
echo "earliest convenience." 
echo "RCMP ECS Team"
echo "------------------------------------------------------------------------"

exit

