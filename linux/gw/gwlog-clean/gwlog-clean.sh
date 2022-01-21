#!/bin/bash - 
#===============================================================================
#
#          FILE: gwlog-clean.sh
# 
#         USAGE: ./gwlog-clean.sh 
# 
#   DESCRIPTION: Remove hostname and IP Address information from a GroupWise POA or MTA log
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
#       CREATED: Wed Aug 08 2012 14:10
#  LAST UPDATED: Tue Mar 13 2018 14:00
#       VERSION: 0.1.5
#     SCRIPT ID: 034
# SSC SCRIPT ID: 00
#===============================================================================
host=$(hostname)             # hostname of the local server
DIALOG=${DIALOG=dialog}      # if you want the script to run in an xwindow (such as xming) change dialog to xdialog.
LOCATION=/tmp/input1.tmp.$$  # user entered location of files to clean
SERVER=/tmp/input2.tmp.$$    # user entered server name to be cleaned
DNS=/tmp/input3.tmp.$$       # user entered dns names to be cleaned
#===============================================================================

# remove temporary files on exit
trap 'rm -f $LOCATION' 0 SIGHUP SIGINT SIGTRAP SIGTERM
trap 'rm -f $SERVER' 0 SIGHUP SIGINT SIGTRAP SIGTERM
trap 'rm -f $DNS' 0 SIGHUP SIGINT SIGTRAP SIGTERM

function show_gpl3(){
$DIALOG --msgbox "log_clean.sh  Copyright (C) 2012  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it under certain conditions." 0 0
}

# Opening note about the script
$DIALOG --help-button --help-label "gpl 3" --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "GroupWise Log Cleaner - removes hostname and IP Addresses" \
		 --msgbox "Please make sure all log files are unpacked before proceeding. During the question phase you can use ctrl+c, ESC, or the cancel button to exit this script. Once the questions have been answered the script will perform the necessary operations on the log files in the specified directory." 0 0

case $? in
	2)
		show_gpl3;;
esac

# Question 1 - where are the supportconfig files?
$DIALOG --colors --title "\Zb\Z0Supportconfig Files location" --clear \
		 --backtitle "GroupWise Log Cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the path to the GroupWise log file location.\nThis must be a local path:" 0 0 2> $LOCATION

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
		 --backtitle "GroupWise Log Cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the name of the GroupWise server.\nThis should be the hostname only:" 0 0 2> $SERVER

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
		 --backtitle "GroupWise Log Cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the domain name of the GroupWise server. Include all portions of the DNS name:" 0 0 2> $DNS

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

FILES=$(cat $LOCATION)
HOST=$(cat $SERVER)
DN=$(cat $DNS)
DN1=$(cat $DNS | cut -f 1 -d . )
DN2=$(cat $DNS | cut -f -2 -d . )

clear

for f in "$FILES"/*
  do
    echo "Removing Hostname and IP Address information from $f ..."
    sed -i 's/'"$HOST"'/hostPrimary/g' "$f"
    sed -i 's/[a-z]\{1,5\}-s[0-9]\{1,4\}/hostSecondary/g' "$f"
    sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-r[0-9]\{1,2\}-v[0-9]\{1,3\}/hostRouter/g' "$f"
    sed -i 's/'"$DN"'/domain.com/g' "$f"
    sed -i 's/'"$DN1"'/domain.com/g' "$f"
    sed -i 's/'"$DN2"'/domain.com/g' "$f"
    sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' "$f"
  done

clear
sleep 2

# Tar up the modified files
echo "Going to tar up the modified files for you now."
sleep 1
pushd .
cd "$FILES" || return
tar jcf "${HOST}"-gw_log_clean_"$(date +'%y%m%d_%H%M')".tbz ./*
popd || return
clear

# Clean up unneeded files
rm -f $LOCATION
rm -f $SERVER
rm -f $DNS

# Exit message to local administrators
echo "==[GroupWise Log Cleaner ]=============================================="
echo "The files from the GroupWise server $host have been cleaned of all" 
echo "hostname and IP Address information, and have been compressed" 
echo "into a tarball. Please e-mail the tarball to your xSE."
echo "------------------------------------------------------------------------"

exit 0
