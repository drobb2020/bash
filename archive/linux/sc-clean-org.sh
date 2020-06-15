#!/bin/bash
REL=0.1-25
##############################################################################
#
#    sc-clean.sh - remove hostname and IP Address information from a 
#                  supportconfig collection
#    Copyright (C) 2013, David Robb 
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
# Date Created: Thu Feb 16 08:38:17 2012 
# Last updated: Fri Jul 11 13:32:18 2014 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog.
DIALOG=${DIALOG=dialog}

BASE=/home/david/sc
LOCATION=/tmp/input1.tmp.$$
SERVER=/tmp/input2.tmp.$$
DNS=/tmp/input3.tmp.$$

trap "rm -f $LOCATION" 0 1 2 5 15
trap "rm -f $SERVER" 0 1 2 5 15
trap "rm -f $DNS" 0 1 2 5 15

function show_gpl3(){
$DIALOG --colors --title "\Zb\Z0Gnu Public License" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostname and IP Addresses" \
		 --msgbox "sc_clean.sh  Copyright (C) 2014  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0
}

# Opening note about the script
$DIALOG --help-button --help-label "gpl 3" --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostname and IP Addresses" \
		 --msgbox "Please make sure all files are unpacked before proceeding.\nDuring the question phase you can use\nctrl+c,\nESC,\nor the cancel button to exit this script.\nOnce the questions have been answered the script will perform the necessary operations on the files in the specified directory.\nsc_clean.sh  Copyright (C) 2014  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0

case $? in
	2)
		show_gpl3;;
esac

# Question 1 - where are the supportconfig files?
$DIALOG --colors --title "\Zb\Z0Supportconfig Files location" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the path to the unpacked supportconfig location. The base path is /home/david/sc.\nPlease complete the remaining path:" 0 0 2> $LOCATION

retval1=$?

case $retval1 in
	1)
		echo "Cancel pressed, goodbye."; exit;;
	255)
		if test -s $LOCATION ; then
			cat $LOCATION
		else
			echo "ESC pressed, goodbye."; exit
		fi
		;;
esac

# Question 2 - Hostname of the server?
$DIALOG --colors --title "\Zb\Z0Server hostname" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the name of the server.\nIf the server name is in uppercase, please enter it here in uppercase.\nThis should be the hostname only:" 0 0 2> $SERVER

retval2=$?

case $retval2 in
	1)
		echo "Cancel pressed, goodbye."; exit;;
	255)
		if test -s $SERVER ; then
			cat $SERVER
		else
			echo "ESC pressed, goodbye."; exit
		fi
		;;
esac

# Question 3 - Domain name of the server?
$DIALOG --colors --title "\Zb\Z0DNS Domain Name" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the domain name of this server. Include all portions of the DNS name\n(eg, rcmp-grc.gc.ca):" 0 0 2> $DNS

retval3=$?

case $retval3 in
	1)
		echo "Cancel pressed, goodbye."; exit;;
	255)
		if test -s $DNS ; then
			cat $DNS
		else
			echo "ESC pressed, goodbye."; exit
		fi
		;;
esac

FILES=`cat $LOCATION`
echo $FILES
HOST=`cat $SERVER`
DN=`cat $DNS`
DN1=$(cat $DNS | cut -f 1 -d . )
DN2=$(cat $DNS | cut -f -2 -d . )
clear

for f in $BASE/$FILES/*
	do
		echo "Removing Hostname and IP Address information from $f ..."
		sed -i 's/'$HOST'/hostPrimary/g' $f
		sed -i 's/[a-z]\{1,5\}-s[0-9]\{1,4\}/hostSecondary/g' $f
		sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-r[0-9]\{1,2\}-v[0-9]\{1,3\}/hostRouter/g' $f
		sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-adr-r/hostRouter/g' $f
		sed -i 's/'$DN'/domain.com/g' $f
		sed -i 's/'$DN1'/domain.com/g' $f
		sed -i 's/'$DN2'/domain.com/g' $f
		sed -i 's/specnatrp/snmptrap/g' $f
		sed -i 's/specnatft/snmptrap/g' $f
		sed -i 's/ehealthp1/snmptrap/g' $f
		sed -i 's/ehealthp2/snmptrap/g' $f
		sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' $f
		sed -i 's/[a-f0-9]\{1,4\}::[0-9]\{1,3\}:[a-f0-9]\{1,4\}:[a-f0-9]\{1,4\}:[0-9]\{1,4\}/xxxx::xxx:xxxx:xxxx:xxxx/g' $f
	done

if [ -d $BASE/$FILES/sar ]
    then
	for f1 in $BASE/$FILES/sar/*
	  do
		echo "Removing Hostname information from $f1 ..."	
		sed -i 's/'$HOST'/hostPrimary/g' $f1
	  done
fi

if [ -d $BASE/$FILES/ldap-ncsvr-files ]
    then
			for f2 in $BASE/$FILES/ldap-ncsvr-files/*
			do
				echo "Removing Hostname and IP Address information from $f2 ..."
				sed -i 's/'$HOST'/hostPrimary/g' $f2
				sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' $f2
			done
fi

clear
sleep 2

# Tar up the modified files
echo "==[Supportconfig Cleaner v$REL]======================================="
echo "Going to tar up the modified files for you now."
echo "------------------------------------------------------------------------"
sleep 1
pushd .
cd $BASE/$FILES
tar jcf nts_${HOST}-clean_$(date +'%y%m%d_%H%M').tbz *
mv *.tbz ../
popd
clear

# Clean up unneeded files
rm -f $LOCATION
rm -f $SERVER
rm -f $DNS
rm -f $BASE/$FILES/*.txt
rm -f $BASE/$FILES/*.xml
rm -f $BASE/$FILES/*.sh
rm -f $BASE/$FILES/*.out
rm -f $BASE/$FILES/*.html
rm -f $BASE/$FILES/*.SEMAPHORE
rm -f $BASE/$FILES/*.b64
rm -Rf $BASE/$FILES/sar
rm -Rf $BASE/$FILES/ldap-ncsvr-files
clear

# Exit message to local administrators
echo "==[Supportconfig Cleaner v$REL]======================================="
echo "The files contained in the supportconfig for server $HOST"
echo "have been cleaned of all hostname and IP Address information."
echo "The files have been recompressed into a tarball." 
echo "Please e-mail the cleaned tarball to your xSE."
echo "------------------------------------------------------------------------"

exit

