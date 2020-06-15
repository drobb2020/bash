#!/bin/bash - 
#===============================================================================
#
#          FILE: edir-restore.sh
# 
#         USAGE: ./edir-restore.sh YYYYMMDD
# 
#   DESCRIPTION: Restore the local instance of eDirectory 8.8.x and all supporting files from a previous backup
#
#                Copyright (C) 2016  David Robb
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
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Feb 25 2011 09:00
#  LAST UPDATED: Sun Jun 19 2016 13:04
#      REVISION: 13
#     SCRIPT ID: 027
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.14
sid=027                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
today=$(date +'%Y%m%d')                         # Today datestamp
ndsconf=/etc/opt/novell/eDirectory/conf         # Path to configuration files for ndsd
ndsbin=/opt/novell/eDirectory/bin               # Path to eDirectory binaries
email=root                                      # who to send email to (comma separated list)
log='/var/log/edir-restore.log'                 # logging (if required)

# Help screen to remind user of commandline syntax
function helpme() { 
	echo "--[ HELP ]-------------------------------------------------------"
	echo "The correct commandline syntax is:"
	echo "./edir-restore.sh YYYYMMDD"
	echo "for example ./edir-restore.sh 20150917"
	echo "================================================================="
	exit 1
}

# Issue a warning before the restore happens
function warning() { 
	echo "--[ WARNING ]----------------------------------------------------"
	echo "This operation will replace all eDirectory files and related"
	echo "configuration files. This should only be done if you are"
	echo "restoring this server from a failed hardware or software upgrade."
	echo "================================================================="
}

# Stop nds daemon
function ndsdstop() { 
  /etc/init.d/ndsd stop
}

# Start nds daemon
function ndsdstrt() { 
  /etc/init.d/ndsd start
}

# Restore eDirectory configuration files
function resedircfg() { 
	/bin/cp -f /backup/$host/edir/ndsbackup/edircfg/nds.conf $ndsconf/nds.conf
	/bin/cp -f /backup/$host/edir/ndsbackup/edircfg/ndsimon.conf $ndsconf/ndsimon.conf
	/bin/cp -f /backup/$host/edir/ndsbackup/edircfg/ndsmodules.conf $ndsconf/ndsmodules.conf
	/bin/cp -f /backup/$host/edir/ndsbackup/edircfg/ndsd /etc/init.d/ndsd
}

# Restore NICI configuration files
function resnicicfg() { 
	/bin/cp -f /backup/$host/edir/ndsbackup/nicicfg/nici.cfg /etc/opt/novell/nici.cfg
	/bin/cp -f /backup/$host/edir/ndsbackup/nicicfg/libccs2.so /opt/novell/lib/libccs2.so
	/bin/cp -f /backup/$host/edir/ndsbackup/nicicfg/libccs2.so.2.7.6 /opt/novell/lib/libccs2.so.2.7.6
}

# Restore NICI files
function resnici() { 
	/bin/cp -f /backup/$host/edir/ndsbackup/nici /var/opt/novell
	/bin/chown -R wwwrun.www /var/opt/novell/nici/30
}

# Restore eDirectory files
function resedir() { 
	/bin/cp -f /backup/$host/edir/ndsbackup/eDirectory /var/opt/novell
}

# Untar the backup archive based on the date entered at the command line
if [ "$#" -lt 1 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  cd /backup/$host/edir
  /bin/tar zxf $(ls | grep $1)
fi

# Do the restore if the user answers yes
warning
while true
do
  read -p "Do you wish to continue with the restoration? (y/n) " YN
  echo "================================================================="
  case $YN in
  [Yy]* ) ndsdstop && resedircfg && resnicicfg && resedir && resnici && ndsdstrt;;
  [Nn]* ) exit 1;;
  * ) echo "Please answer yes (y) or no (n).";;
  esac
done

# Check ndsd status after the restore
$ndsbin/ndsstat -s

# Send restore report
if [ -n $email ]; then
  echo -e "An eDirectory restore has been performed on $host.\nIf you did not perform this restore, please investigate to find out who did, and document the reason.\nAll eDirectory and NICI files have been restored to their original locations. This restore does not affect the installed RPM packages for eDirectory and NICI.\n\nThank you." | mail -s "$host eDir Restore Report" $email
fi

# Finished
exit 1

