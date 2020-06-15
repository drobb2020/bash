#!/bin/bash - 
#===============================================================================
#
#          FILE: nds-backup.sh
# 
#         USAGE: ./nds-backup.sh 
# 
#   DESCRIPTION: Backup all eDirectory objects from an OES Server
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
#       CREATED: Tue Feb 12 2013 16:48
#   LAST UDATED: Tue Mar 13 2018 10:37
#       VERSION: 0.1.11
#     SCRIPT ID: 028
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.11                                   # version number of the script
sid=028                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=eDirectory-backup                          # email sender
email=root                                       # email recipient(s)
log='/var/log/nds-backup.log'                    # log name and location (if required)
ndsconf=/etc/opt/novell/eDirectory/conf          # path to nds configuration files
ndsbin=/opt/novell/eDirectory/bin                # path to eDirectory binaries
fn=$host-full-$df                                # file name
admin=                                           # administrator (FDN) account
pswd=                                            # administrator's password
#===============================================================================

# Create the necessary folders
if [ -d /backup/nds ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$host/nds
fi

if [ -d /var/log/ndsbackup ]; then
  echo "Directoru exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /var/log/ndsbackup
fi

# Setup and initialize logging
function initlog() { 
  if [ -e ${log} ]; then
    echo "log file exists"
  else
    echo "Logging started at ${ts}" > ${log}
    echo "All actions are being performed by the user: ${user}" >> ${log}
    echo " " >> ${log}
  fi
}

initlog

# Backup eDirectory objects
$ndsbin/ndsbackup cvf /backup/$host/nds/$fn -a $admin -p $pswd | tee -a $log

# mail message body
funcion mail_body1() { 
echo -e "Please find attached the nds backup log for $host."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NDS Backup log for $host" -r $mfrom $email < $log
fi

# Finished
exit 1

