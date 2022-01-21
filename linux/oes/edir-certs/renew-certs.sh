#!/bin/bash - 
#===============================================================================
#
#          FILE: renew-certs.sh
# 
#         USAGE: ./renew-certs.sh 
# 
#   DESCRIPTION: Certificate renewal script for the regional trees
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
#       CREATED: Thu Dec 04 2014 11:45
#  LAST UPDATED: Thu Mar 15 2018 10:49
#       VERSION: 0.1.6
#     SCRIPT ID: 048
# SSC SCRIPT ID: 25
#===============================================================================
host=$(hostname)                          # hostname of the local server
user=$(whoami)                            # who is running the script
admin=/tmp/adm.$$.tmp                     # administrators account name FQN
pswd=/tmp/pswd.$$.tmp                     # administrator's password
ndslog="/var/opt/novell/eDirectory/log"   # path to nds log
ndsbin="/opt/novell/eDirectory/bin"       # path to nds binaries
DIALOG=${DIALOG=dialog}                   # if you want the script to run 
                                          # in an x windows (such as xming) 
																					# change dialog to xdialog
#===============================================================================

# Must be root to run script!
if [ "$user" != "root" ]; then
  echo "You must be root to run this script, but you are: $user."
  echo "The script will now exit. Please sudo to root and try again."
  exit 1
fi

# Clean up old log files, so we only see the stuff we do
if [ -e $ndslog/PKIHealth.log ]; then
  rm -f $ndslog/PKIHealth.log
else
  echo "PKIHealth log doesn't exist, continuing..."
fi

if [ -e $ndslog/ndsrepair.log ]; then
  rm -f $ndslog/ndsrepair.log
else
  echo "ndsrepair log doesn't exist, continuing..."
fi

# Gather account name and password
# Question 1 - Administrators name
$DIALOG --colors --title "\Zb\Z0Your Administrator Account Name" --clear \
		 --backtitle "eDirectory certificate update script" \
		 --inputbox "Please enter your administrator's account name and context, eg. cn=adminrc,o=cen:" 0 0 2> $admin

retval1=$?

case $retval1 in
  1)
    echo "Cancel pressed, goodbye."; clear; exit;;
  255)
    if test -s $admin ; then
      cat $admin
    else
      echo "ESC pressed, goodbye."; clear; exit
    fi
    ;;
esac

# Question 2 - Administrator's password
$DIALOG --colors --title "\Zb\Z0Administrator's Password" --clear \
		 --backtitle "eDirectory certificate update script" \
		 --insecure \
		 --passwordbox "Please enter your password:" 0 0 2> $pswd

retval2=$?

case $retval2 in
  1)
    echo "Cancel pressed, goodbye."; clear; exit;;
  255)
    if test -s $pswd ; then
      cat $pswd
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
  $ndsbin/ndsrepair -R -l yes
else
  echo "--[ Failure ]---------------------------------------------------"
  echo "The eDirectory daemon ndsd doesn't seem to be running correctly."
  echo "Please restart ndsd manually, and rerun this script."
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
  echo "Please attempt a manual restart, and check the log $ndslog/ndsd.log for errors."
fi
sleep 2

# Update LUM with the account named entered earlier
/usr/bin/namconfig set admin-fdn="$(cat /tmp/adm.$$.tmp)"

# Run namconfig -k to re-mint the certificates for LUM
LUM_PWD=$(cat /tmp.pwd.$$)
export LUM_PWD
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
rm -f /tmp/*.$$.tmp
clear

# Final message
echo "--[ Default SSL certificates ]-------------------------------------"
echo "The default certificates for $host have been renewed, and will"
echo "now expire in 2 years. To verify that this script worked you"
echo "can review the PKI Health log and the ndsrepair log. These can"
echo "be found under /var/opt/novell/eDirectory/log."
echo "If you have any questions or issues with this script please contact"
echo "Rene Clairoux, rene.clairoux@ssc-spc.gc.ca, 613-993-6118"
echo "==================================================================="

exit 0
