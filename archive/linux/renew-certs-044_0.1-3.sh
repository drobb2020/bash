#!/bin/bash
REL=0.1-3
SID=044
ID=23
##############################################################################
#
#    renew-certs.sh - OES2 SP2 Certificate renewal script for the CENTRAL tree
#                     RCMPWF tree, and ATLANTIC Tree.
#    Copyright (C) 2014  David Robb
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
# Date Created: Thu Dec 04 11:45:55 2014 
# Last updated: Wed May 27 15:23:57 2015 
# Crontab command: 
# Supporting file: None
# Additional notes: 
##############################################################################
# If you want the script to run in an x windows (such as xming) change dialog to xdialog
DIALOG=${DIALOG=dialog}
HOST=$(hostname)
TS=$(date +"%b %d %T")
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
ADM=/tmp/adm.tmp.$$
PWD=/tmp/pwd.tmp.$$
NDSLOG="/var/opt/novell/eDirectory/log"
NDSBIN="/opt/novell/eDirectory/bin"

# Must be root to run script!
if [ $USER != "root" ]; then
  echo "You must be root to run this script, but you are: $USER."
  echo "The script will now exit. Please sudo to root and try again."
  exit 1
fi

# Clean up old log files, so we only see the stuff we do
if [ -e $NDSLOG/PKIHealth.log ]; then
  rm -f $NDSLOG/PKIHealth.log
else
  echo "PKIHealth log doesn't exist, continuing..."
fi

if [ -e $NDSLOG/ndsrepair.log ]; then
  rm -f $NDSLOG/ndsrepair.log
else
  echo "ndsrepair log doesn't exist, continuing..."
fi

# Gather account name and password
# Question 1 - Administrators name
$DIALOG --colors --title "\Zb\Z0Your Administrator Account Name" --clear \
		 --backtitle "V$REL eDirectory certificate update script" \
		 --inputbox "Please enter your administrator's account name and context, eg. cn=adminrc,o=cen:" 0 0 2> $ADM

retval1=$?

case $retval1 in
  1)
    echo "Cancel pressed, goodbye."; clear; exit;;
  255)
    if test -s $ADM ; then
      cat $ADM
    else
      echo "ESC pressed, goodbye."; clear; exit
    fi
    ;;
esac

# Question 2 - Administrator's password
$DIALOG --colors --title "\Zb\Z0Administrator's Password" --clear \
		 --backtitle "V$REL eDirectory certificate update script" \
		 --insecure \
		 --passwordbox "Please enter your password:" 0 0 2> $PWD

retval2=$?

case $retval2 in
  1)
    echo "Cancel pressed, goodbye."; clear; exit;;
  255)
    if test -s $PWD ; then
      cat $PWD
    else
      echo "ESC pressed, goodbye."; clear; exit
    fi
    ;;
esac
sleep 2

# Run an ndsrepair to generate the new certs for the server
/etc/init.d/ndsd status &>/dev/null
ndsdReturnCode=$?
if [ $ndsdReturnCode == 0 ]; then
  $NDSBIN/ndsrepair -R -l yes
else
  echo "--[ Failure ]---------------------------------------------------"
  echo "The eDirectory daemon ndsd doesn't seem to be running correctly."
  echo "Pleaes restart ndsd manually, and rerun this script."
  rm -f /tmp/*.tmp.$$
  clear
  exit 1
fi
clear
sleep 2

# Restart eDirectory so the new certs are being used
/etc/init.d/ndsd status &>/dev/null
ndsdReturnCode2=$?
if [ $ndsdReturnCode2 == 0 ]; then
  echo "--[ Restart ]-------------------------------"
  echo "Restarting ndsd to load new SSL certificates" 
  /etc/init.d/ndsd restart
fi
# Check to make sure ndsd is running
/etc/init.d/ndsd status &>/dev/null
ndsdReturnCode3=$?
if [ $ndsdReturnCode3 == 0 ]; then
  echo "--[ Success ]-----------------------------------"
  echo "ndsd successfully restarted."
else
  echo "--[ Failure ]-----------------------------------"
  echo "For some reason the last restart of ndsd failed."
  echo "This may be due to a misconfiguration."
  echo "Please attempt a manual restart, and check the log (/var/log/ndsd.log) for errors."
fi
sleep 2

# Update LUM with the accout named entered earlier
/usr/bin/namconfig set admin-fdn=$(cat /tmp/adm.tmp.$$)

# Run namconfig -k to remint the certificates for LUM
export LUM_PWD=$(cat /tmp/pwd.tmp.$$)
sleep 1
/usr/bin/namconfig -k
unset LUM_PWD
clear

# Run namconfig cache_refresh to restart LUM
/etc/init.d/namcd status &>/dev/null
namcdReturnCode=$?
if [ $namcdReturnCode == 0 ]; then
  echo "--[ Restart ]--------------------------"
  echo "Restarting namcd to enable all changes."
  /usr/bin/namconfig cache_refresh
fi
# Check new status of daemon (lets hope it's running)
/etc/init.d/namcd status &>/dev/null
namcdReturnCode2=$?
if [ $namcdReturnCode2 == 0 ]; then
  echo "--[ Success ]-----------------------"
  echo "namcd daemon successfully restarted."
else
  echo "--[ Failure ]----------------------------------------"
  echo "For some reason the last restart of namcd failed."
  echo "This may be due to a misconfiguration."
  echo "Please attempt a manual restart, and check the log (/var/log/namcd.log) for errors."
fi

# All done - cleanup
rm -f /tmp/*.tmp.$$
clear

# Final message
echo "--[ Default SSL certificates ]-------------------------------------"
echo "The default certificates for $HOST have been renewed, and will"
echo "now expire in 2 years. To verify that this script worked you"
echo "can review the PKI Health log and the ndsrepair log. These can"
echo "be found under /var/opt/novell/eDirectory/log."
echo "If you have any questions or issues with this script please contact"
echo "Rene Clairoux, rene.clairoux@ssc-spc.gc.ca, 613-993-6118"
echo "==================================================================="

exit 1

