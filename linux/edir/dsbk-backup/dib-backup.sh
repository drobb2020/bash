#!/bin/bash - 
#===============================================================================
#
#          FILE: dib-backup.sh
# 
#         USAGE: ./dib-backup.sh 
# 
#   DESCRIPTION: Backup the DIB set and NICI files on an OES2/OES11 server
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
#       OPTIONS: 00 3 * * * /root/bin/dib-backup.sh
#  REQUIREMENTS: rfl must be configured on a server using this backup method
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: Remember to set a password to protect the NICI keys
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tue Oct 02 2012 14:32
#  LAST UPDATED: Tue Mar 13 2018 09:10
#       VERSION: 0.1.9
#     SCRIPT ID: 022
# SSC SCRIPT ID: 00
#===============================================================================
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
mfrom=                                           # email sender
email=                                           # email recipient(s)
ndsbin=/opt/novell/eDirectory/bin               # Location of eDirectory binaries
fn=$host$df                                     # Backup file filename
pswd=                                           # Password to protect NICI keys
#===============================================================================
# Source in the dsbk prep script
. ~/bin/dsbkprep.sh

# Create the necessary folders
if [ -d /backup/"$host"/dib ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/"$host"/dib
fi

if [ -d /var/log/dibbackup ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /var/log/dibbackup
fi

# Backup the DIB set and NICI keys each day of the week
$ndsbin/dsbk backup -b -f /backup/"$host"/dib/"$fn".dib -l /var/log/dibbackup/"$df".log -e "$pswd" -t -w

# E-mail results
sleep 15
if [ -n "$email" ]; then
  mail -s "DIB and NICI Backup log for $host" -r "$mfrom" "$email" < /var/log/dibbackup/"$df".log
fi

# Finished
exit 0
