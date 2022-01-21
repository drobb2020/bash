#!/bin/bash
DIALOG=${DIALOG=dialog}
SL=/tmp/sl.tmp.$$
SC=/tmp/sc.tmp.$$

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

# SNMP Configuration
echo "Changing SNMP configuration"
SC0=$(grep -w syscontact /etc/snmp/snmpd.conf | grep -v "#")
SL0=$(grep -w syslocation /etc/snmp/snmpd.conf | grep -v "#")
sed -i "s/$SC0/syscontact/" /etc/snmp/snmpd.conf
sed -i "s/$SL0/syslocation/" /etc/snmp/snmpd.conf
echo -e rwcommunity no 127.0.0.1 >> /etc/snmp/snmpd.conf
/etc/init.d/snmpd restart
sleep 2
/usr/bin/snmpset -c no -v 1 localhost system.sysContact.0 s "$(cat /tmp/sc.tmp.$$)"
/usr/bin/snmpset -c no -v 1 localhost system.sysLocation.0 s "$(cat /tmp/sl.tmp.$$)"
SC1=$(grep -w syscontact /etc/snmp/snmpd.conf | grep -v "#")
SL1=$(grep -w syslocation /etc/snmp/snmpd.conf | grep -v "#")
sed -i "s/$SC1/syscontact $(cat /tmp/sc.tmp.$$)/" /etc/snmp/snmpd.conf
sed -i "s/$SL1/syslocation $(cat /tmp/sl.tmp.$$)/" /etc/snmp/snmpd.conf
echo "SNMP configuration is complete."
sleep 2
clear
