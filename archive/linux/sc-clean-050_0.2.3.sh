#!/bin/bash
REL=0.2-3
SID=050
##############################################################################
#
#    sc-clean.sh - remove hostname and IP Address information from a 
#                  supportconfig collection
#    Copyright (C) 2014, David Robb 
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
# Date Created: Fri Jul 11 13:40:12 2014 
# Last updated: Thu May 28 08:30:21 2015 
# Crontab command: Not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog.
DIALOG=${DIALOG=dialog}
USER=$(whoami)
TS=$(date +"%b %d %T")
LOG=/home/david/sc/sc-cleaning.log
BASE=/home/david/sc
LOCATION=/tmp/input1.tmp.$$
SERVER=/tmp/input2.tmp.$$
DNS=/tmp/input3.tmp.$$

trap "rm -f $LOCATION" 0 1 2 5 15
trap "rm -f $SERVER" 0 1 2 5 15
trap "rm -f $DNS" 0 1 2 5 15

function initlog() { 
  if [ -e /home/david/sc/sc-cleaning.log ]; then
    echo "log file exists" > /dev/null
  else
    touch /home/david/sc/sc-cleaning.log
    echo "Logging started at ${TS}" > ${LOG}
    echo "All actions are being performed by the user: ${USER}" >> ${LOG}
    echo " " >> ${LOG}
  fi
}

function logit() { 
  echo -e $TS $HOST: $* >> ${LOG}
}

initlog

# Opening note about the script
$DIALOG --colors --title "\Zb\Z0How to exit the script" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostname and IP Addresses" \
		 --msgbox "Please make sure all files are unpacked before proceeding.\nDuring the question phase you can use:\nctrl+c,\nESC,\nor the cancel button to exit this script.\nOnce the questions have been answered the script will perform the necessary operations on the files in the specified directory.\n-----------------------------------------------------------------\nsc-clean.sh  Copyright (C) 2014  David Robb\nThis program comes with ABSOLUTELY NO WARRANTY.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions." 0 0

# Get the location of the unpacked supportconfig
$DIALOG --colors --title "\Zb\Z0Supportconfig Files location" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the path to the unpacked supportconfig location. The base path is /home/david/sc.\nPlease fill in the remaining path\neg: cas-sac/nts_acpic-s0000_140808_1000:" 0 0 2> $LOCATION

retval1=$?

case $retval1 in
  1)
    echo "Good bye."; exit;;
  255)
    if test -s $LOCATION ; then
      cat $LOCATION
      else
      echo "Good bye."; exit
    fi
    ;;
esac

# grep the server name from the directory name
SRV=$(cat /tmp/input1.tmp.$$ | cut -f 2 -d "/" | cut -f 2 -d "_")
echo -e "$SRV" > /tmp/input2.tmp.$$

# Get the domain name for the server
$DIALOG --colors --title "\Zb\Z0DNS Domain Name" --clear \
		 --backtitle "v$REL Supportconfig cleaner - removes hostnames and IP Addresses" \
		 --inputbox "Please enter the domain name of this server. Include all portions of the DNS name\n(eg, ross.rcmp-grc.gc.ca):" 0 0 2> $DNS

retval2=$?

case $retval2 in
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
HOST=`cat $SERVER`
DN=`cat $DNS`
DN1=$(cat $DNS | cut -f 1 -d . )
DN2=$(cat $DNS | cut -f -2 -d . )
clear

echo "-----------------------------------------------------------------------------------" | tee -a $LOG
logit "New supportconfig cleaning started at: $TS"
echo "==[Supportconfig Cleaner v$REL]===================================================" | tee -a $LOG
echo "You set the file location as:" $BASE/$FILES | tee -a $LOG
echo "The server name is:" $HOST | tee -a $LOG
echo "The domain name is:" $DN | tee -a $LOG
echo "-----------------------------------------------------------------------------------" | tee -a $LOG

sleep 5
clear

if [ -d $BASE/$FILES ]; then
  for f in $BASE/$FILES/*	
  do
    echo "Removing Hostname and IP Address information from $f ..." | tee -a $LOG
    sed -i 's/'$HOST'/hostPrimary/g' $f | tee -a $LOG
    sed -i 's/[a-z]\{1,5\}-s[0-9]\{1,4\}/hostSecondary/g' $f | tee -a $LOG
    sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-r[0-9]\{1,2\}-v[0-9]\{1,3\}/hostRouter/g' $f | tee -a $LOG
    sed -i 's/[a-z]\{1,5\}-r[0-9]\{1,2\}-adr-r/hostRouter/g' $f | tee -a $LOG
    sed -i 's/'$DN'/domain.com/g' $f | tee -a $LOG
    sed -i 's/'$DN1'/domain.com/g' $f | tee -a $LOG
    sed -i 's/'$DN2'/domain.com/g' $f | tee -a $LOG
    sed -i 's/specnatrp/snmptrap/g' $f | tee -a $LOG
    sed -i 's/specnatft/snmptrap/g' $f | tee -a $LOG
    sed -i 's/ehealthp1/snmptrap/g' $f | tee -a $LOG
    sed -i 's/ehealthp2/snmptrap/g' $f | tee -a $LOG
    sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' $f | tee -a $LOG
    sed -i 's/[a-f0-9]\{1,4\}::[0-9]\{1,3\}:[a-f0-9]\{1,4\}:[a-f0-9]\{1,4\}:[0-9]\{1,4\}/xxxx::xxx:xxxx:xxxx:xxxx/g' $f | tee -a $LOG
  done
else
  echo -e "The supportconfig was not found at the location specified, please try again." | tee -a $LOG
  exit 1
fi

if [ -d $BASE/$FILES/sar ]; then
  for f1 in $BASE/$FILES/sar/*
  do
    echo "Removing Hostname information from $f1 ..." | tee -a $LOG
    sed -i 's/'$HOST'/hostPrimary/g' $f1  | tee -a $LOG
  done
fi

if [ -d $BASE/$FILES/ldap-ncsvr-files ]; then
  for f2 in $BASE/$FILES/ldap-ncsvr-files/*
  do
    echo "Removing Hostname and IP Address information from $f2 ..." | tee -a $LOG
    sed -i 's/'$HOST'/hostPrimary/g' $f2 | tee -a $LOG
    sed -i 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/xxx.xxx.xxx.xxx/g' $f2 | tee -a $LOG
  done
fi

# Finished Cleaning files
echo "==[Supportconfig Cleaner v$REL]======================================="
echo "All files in the collection have been cleaned of IP Address"
echo "and hostname information."
echo "Cleaning completed at: $TS"
echo "-----------------------------------------------------------------------"
sleep 1
logit "All files in the collection have been cleaned of IP Address and hostname information."
logit "Cleaning completed at: $TS"
clear

# Tar up the modified files
echo "==[Supportconfig Cleaner v$REL]======================================="
echo "Going to tar up the modified files for you now."
echo "-----------------------------------------------------------------------"
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
if [ $USER != "david" ]; then
  echo "==[Supportconfig Cleaner v$REL]======================================="
  echo "The files contained in the supportconfig for server $HOST"
  echo "have been cleaned of all hostname and IP Address information."
  echo "The files have been recompressed into a tarball." 
  echo "Please e-mail the cleaned tarball to your xSE."
  echo "-----------------------------------------------------------------------"
else
  echo "You know where to find the file..."
fi

exit 1

