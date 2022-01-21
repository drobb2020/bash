#!/bin/bash - 
#===============================================================================
#
#          FILE: dib-restore.sh
# 
#         USAGE: ./dib-restore.sh 
# 
#   DESCRIPTION: Restore eDirectory and NICI on an OES server from a previous backup.
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
#       CREATED: Tue Oct 02 2012 14:32
#  LAST UPDATED: Tue Mar 13 2018 10:03
#       VERSION: 0.1.7
#     SCRIPT ID: 024
# SSC SCRIPT ID: 00
#===============================================================================
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
mfrom=dsbk-restore                               # email sender
email=root                                       # email recipient(s)
ndsbin=/var/opt/novell/eDirectory/bin            # path to nds binaries
pswd=                                            # Password for NICI keys, should be the 
                                                 # same as in the dib-backup.sh script
#===============================================================================
function helpme() {
  echo "WARNING"
  echo "-------------------------------------------------------------------"
  echo "The correct command line syntax is ./dib-restore.sh /path/to/dib"
  echo "for example ./dib-restore.sh /backup/dib/acpic-s2740Tuesday.dib"
  echo "==================================================================="
  exit 1
}

# check the command line options and do a restore
if [ $# -lt 1 ]; then
  echo "There are not enough options on the command line."
	helpme
else	
  $ndsbin/dsbk restore -r -f /backup/dib/"$1".dib -l /var/log/dibbackup/"$df".log -d /var/rfl/logs -e "$pswd" -a -o
fi

# E-mail results
if [ -n "$email" ]; then
  mail -s "DIB Restore performed on $host" -r $mfrom $email < /var/log/dibbackup/"$df".log
fi

# Finished
exit 0
