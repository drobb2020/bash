#!/bin/bash - 
#===============================================================================
#
#          FILE: oes-tuning.sh
# 
#         USAGE: ./oes-tuning.sh 
# 
#   DESCRIPTION: OES Post Installation Tuning script
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
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Fri Nov 09 2012 09:55
#  LAST UPDATED: Thu Mar 15 2018 14:28
#       VERSION: 0.2.1
#     SCRIPT ID: 051
# SSC SCRIPT ID: 00
#===============================================================================

DIALOG=${DIALOG=dialog}                          # if you want the script to run in an x windows (such as xming) change dialog to xdialog.
IP1=/tmp/ip1.tmp.$$                              # ip address for LUM configuration
IP2=/tmp/ip2.tmp.$$                              # ip address for LUM configuration
IP3=/tmp/ip3.tmp.$$                              # ip address for LUM configuration
P1=/tmp/p1.tmp.$$                                # port assignment for ssh
ADM2=/tmp/adm2.tmp.$$                            # administrator's account name 
PSWD=/tmp/pswd.tmp.$$                            # administrator's password
VOLS=/tmp/vols.tmp.$$                            # list of NSS volumes
ndsbin=/opt/novell/eDirectory/bin                # path to nds binaries
# ndssbin=/opt/novell/eDirectory/sbin              # path to nds supervisor binaries
ncpsbin=/opt/novell/ncpserv/sbin                 # path to ncp supervisor binaries
nsssbin=/opt/novell/nss/sbin                     # path to nss supervisor binaries
# dibdir=$($ndsbin/ndsconfig get | grep n4u.nds.dibdir | cut -f 2 -d "=") # path to dibset
#===============================================================================

function show_gpl3(){
$DIALOG --msgbox "oes-tuning.sh  Copyright (C) 2015  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0
}

# Opening note about the script
$DIALOG --help-button --help-label "gpl 2" --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --msgbox "This script will automatically apply the recommended post installation configuration to your server. During the question phase you can use ctrl+c, ESC, or the cancel button to exit this script. Once the questions have been answered the script will perform the changes to the server." 0 0

case $? in
	2)
		show_gpl3;;
esac

$DIALOG --colors --title "\Zb\Z0LUM configuration" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --msgbox "Linux User Management (LUM) best practices requires that the local server points to itself as the preferred server, whether or not the local server holds a replica." 0 0

# Question 1 - Server IP Address for LUM?
$DIALOG --colors --title "\Zb\Z0This Server's IP Address" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
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
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --msgbox "The alternative LDAP server list is used when the preferred server is not responding.\nAlternate servers should be on the same LAN segment, and not across slow WAN links." 0 0

# Question 2 - First IP Address of Alternate-ldap server for LUM?
$DIALOG --colors --title "\Zb\Z0IP Address of a first alternative OES server" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --inputbox "Please enter the IP Address of the first alternative LDAP server for LUM configuration:" 0 0 2> $IP2

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
$DIALOG --colors --title "\Zb\Z0IP Address of a second alternative OES server" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --inputbox "Please enter the IP Address of the second alternative LDAP server for LUM configuration:" 0 0 2> $IP3

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
$DIALOG --colors --title "\Zb\Z0High port number for SSH" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --inputbox "Please enter the desired high port number for SSH configuration, or 22 for the default:" 0 0 2> $P1

retval4=$?

case $retval4 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $P1 ; then
			cat $P1
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac
clear

# Question 5 - eDirectory admin account for ldapconfig
$DIALOG --colors --title "\Zb\Z0Name of Administrator account" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --inputbox "Please enter the account name of a user that has admin rights to the Tree:" 0 0 2> $ADM2

retval5=$?

case $retval5 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $ADM2 ; then
			cat $ADM2
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac
clear

# Question 6 - Password for admin account in question 5?
$DIALOG --colors --title "\Zb\Z0Password" --clear \
		 --backtitle "OES2 Post Installation Tuning Script" \
		 --passwordbox "Please enter the password for the account:" 0 0 2> $PSWD

retval6=$?

case $retval6 in
	1)
		echo "Cancel pressed, goodbye."; clear; exit;;
	255)
		if test -s $PSWD ; then
			cat $PSWD
		else
			echo "ESC pressed, goodbye."; clear; exit
		fi
		;;
esac
clear

# NSS Configuration
# VOLLS=$(echo -e 'c\nvolumes\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep ACTIVE | grep -v \_ADMIN > $VOLS)
echo "Updating NSS configuration"
echo -e 'c\nvolumes\n\nexit' | $nsssbin/nsscon | sed -e 's/\x1b\[[^m]*m//g;s/\[[^c]//g;s/\x1b\J//g' | grep ACTIVE | cut -f 1 -d " " | grep -v \_ADMIN >> $VOLS

vollist=""
n=1
for vol in $(cat $VOLS)
do
        vollist="$vollist $vol $n off"
        n=$((n+1))
done

choices=$(/usr/bin/dialog --stdout --colors \
                         --title "\Zb\ZOAccess Time" \
			 --backtitle "OES2 Post Installation Tuning Script" \
		         --checklist 'Select the volumes you want to disable last access time on:' 20 30 10 "$vollist")

if [ "$?" -eq 0 ]; then
  for choice in $choices
  do
    echo -e "/NoATime=$choice" > /dev/nsscmd
  done
else
  echo "Bye"
fi

vollist2=""
n=1
for vol in $(cat $VOLS)
  do
    vollist2="$vollist2 $vol $n off"
    n=$((n+1))
  done

choices2=$(/usr/bin/dialog --stdout --colors \
			  --title "\Zb\ZOData Salvage" \
			  --backtitle "OES2 Post Installation Tuning Script" \
			  --checklist 'Select the volumes you want to disable salvage on:' 20 30 10 "$vollist2")

if [ "$?" -eq 0 ]; then
  for choice2 in $choices2
  do
    echo -e "/NoSalvage=$choice2" > /dev/nsscmd
  done
else
  echo cancel selected
fi

echo "/IDCacheSize=131072" >> /etc/opt/novell/nss/nssstart.cfg
echo "NSS configuration complete."
sleep 2

# SSH Configuration
echo "Updating SSH configuration"
echo "Going to set the ssh port to $(cat $P1)"
sleep 2

echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Port $(cat $P1)" >> /etc/ssh/sshd_config

rcsshd restart
echo "SSH configuration complete."
sleep 5

# LUM Configuration
echo "Updating LUM/NAMCD configuration"
echo "The preferred server address is: $(cat $IP1)"
echo "The first alternative address is: $(cat $IP2)"
echo "The second alternative address is: $(cat $IP3)"
sleep 10

/usr/bin/namconfig set preferred-server="$(cat $IP1)"
/usr/bin/namconfig set alternative-ldap-server-list="$(cat $IP2)","$(cat $IP3)"
/usr/bin/namconfig set persistent-search=no
/usr/bin/namconfig set persistent-cache-refresh-period=3600
/usr/bin/namconfig set log-file-location=/var/log/
/usr/bin/namconfig set log-level=3

rcnamcd restart
sleep 2
ADM1=$(namconfig get | grep admin-fdn | cut -f 2- -d "=")
echo "You will need the password of the user listed in namconfig, which is: $ADM1"
sleep 2
/usr/bin/namconfig -k
/usr/bin/namconfig cache_refresh

echo "LUM configuration is complete."

# Create a log rotation script for namcd.log
echo "Creating log rotation script for namcd.log"
echo -e '/var/log/namcd.log {' >> /etc/logrotate.d/namcd
echo -e '\tcompress' >> /etc/logrotate.d/namcd
echo -e '\tdateext' >> /etc/logrotate.d/namcd
echo -e '\tmaxage 30' >> /etc/logrotate.d/namcd
echo -e '\trotate 99' >> /etc/logrotate.d/namcd
echo -e '\tsize=+2480k' >> /etc/logrotate.d/namcd
echo -e '\tnotifenpty' >> /etc/logrotate.d/namcd
echo -e '\tmissingok' >> /etc/logrotate.d/namcd
echo -e '\tcopyturncate' >> /etc/logrotate.d/namcd
echo -e '\tpostrotate' >> /etc/logrotate.d/namcd
echo -e '\t\tchmod 644 /var/log/namcd.log' >> /etc/logrotate.d/namcd
echo -e '\tendscript' >> /etc/logrotate.d/namcd
echo -e '}' >> /etc/logrotate.d/namcd

sleep 5

# NCP Configuration
echo "Updating NCP configuration"
$ncpsbin/ncpcon set CROSS_PROTOCOL_LOCKS=1
$ncpsbin/ncpcon set FIRST_WATCHDOG_PACKET=5
$ncpsbin/ncpcon set CONCURRENT_ASYNC_REQUESTS=75
$ncpsbin/ncpcon set MAXIMUM_CACHED_FILES_PER_SUBDIRECTORY=6000
$ncpsbin/ncpcon set MAXIMUM_CACHED_FILES_PER_VOLUME=120000
$ncpsbin/ncpcon set MAXIMUM_CACHED_SUBDIRECTORIES_PER_VOLUME=300000

/etc/init.d/ncp2nss restart
echo "NCP configuration is complete."
sleep 5

# Novell CIFS Configuration
if [ -e /etc/init.d/novell-cifs ] ; then
  echo "Updating CIFS configuration"
  /usr/sbin/novcifs -k SDIRCACHE=1024000
  /usr/sbin/novcifs -k DIRCACHE=102400
  /usr/sbin/novcifs -k FILECACHE=2048000
  /etc/init.d/novell-cifs restart
  echo "CIFS configuration is complete"
  sleep 5
fi

# NDS Configuration
echo "Updating NDS configuration"
echo "NDSD_TRY_NMASLOGIN_FIRST=true" >> /opt/novell/eDirectory/sbin/pre_ndsd_start
echo "export NDSD_TRY_NMASLOGIN_FIRST" >> /opt/novell/eDirectory/sbin/pre_ndsd_start
echo "nmas LoginInfo 1" >> /var/opt/novell/eDirectory/data/nmas.config
echo "nmas RefreshRate 300" >> /var/opt/novell/eDirectory/data/nmas.config
/bin/chmod 644 /var/opt/novell/eDirectory/data/nmas.config
$ndsbin/ndsconfig set n4u.nds.advertise-life-time=1800
$ndsbin/ndsconfig set n4u.server.max-threads=256
echo -e 'c\nset ndstrace=!ARC1\nexit' | $ndsbin/ndstrace
$ndsbin/ldapconfig set "ldapEnablePSearch=no" -a $ADM2 -w $PSWD

rcndsd restart
echo "NDS configuration is complete."
sleep 5

# TCP Configuration
echo "Updating TCP configuration"
echo 600 > /proc/sys/net/ipv4/tcp_keepalive_time
echo 60 > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo 20 > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "net.ipv4.tcp_keepalive_time = 600"; echo "net.ipv4.tcp_keepalive_intvl = 60"; echo "net.ipv4.tcp_keepalive_probes = 20" >> /etc/sysctl.conf

echo "TCP configuration is complete."
sleep 5

# UDEV Configuration
echo "Updating UDEV configuration"
MEM=$(grep MemTotal /proc/meminfo | cut -f 8 -d " ")
MEMG=$(echo "scale=3; $MEM/1000000" | bc)
UDEVNEWVAL=$(echo "(128 +(125 * $MEMG)) * 2" | bc | cut -f 1 -d ".")
UDEV1=$(grep -w UDEVD_MAX_CHILDS /etc/sysconfig/udev | cut -f 2 -d "=")
UDEV2=$(grep -w UDEVD_MAX_CHILDS_RUNNING /etc/sysconfig/udev | cut -f 2 -d "=")

echo "The current udev value for max childs is: $UDEV1"
echo "The current udev value for max childs running is: $UDEV2"
echo "The new udev value for both will be: $UDEVNEWVAL"

sed -i "s/UDEVD_MAX_CHILDS=$UDEV1/UDEVD_MAX_CHILDS=$UDEVNEWVAL/" /etc/sysconfig/udev
sed -i "s/UDEVD_MAX_CHILDS_RUNNING=$UDEV2/UDEVD_MAX_CHILDS_RUNNING=$UDEVNEWVAL/" /etc/sysconfig/udev

echo "UDEV configuration is complete."

clear

# Clean up unneeded files
rm -f $IP1
rm -f $IP2
rm -f $IP3
rm -f $P1
rm -f $ADM2
rm -f $PSWD
rm -f $VOLS

clear
echo "========================================================================"
echo "OES2 Post Installation script"
echo "All required tuning parameters have been applied to this server." 
echo "To ensure all changes take effect please reboot the server at your"
echo "earliest convenience." 
echo "------------------------------------------------------------------------"

exit 1

