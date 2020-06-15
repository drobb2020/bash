#!/bin/bash - 
#===============================================================================
#
#          FILE: nmaserr_detect.sh
# 
#         USAGE: ./nmaserr_detect.sh 
# 
#   DESCRIPTION: Script to parse /var/log/messages to look for NMAS error messages
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
#       OPTIONS: */5 * * * * /path/to/script/nmaserr_detect.sh
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Fri Jan 08 2016 08:41
#   LAST UDATED: Thu Mar 15 2018 08:15
#       VERSION: 0.1.3
#     SCRIPT ID: 067
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.3                                    # version number of the script
sid=067                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=nmas-error-detection                       # email sender
email=root                                       # email recipient(s)
log='/var/log/nmaserr_detect.log'                # log name and location (if required)
mlog='/var/log/messages'                         # path to messages log
#===============================================================================

# tail the current messages log 
/usr/bin/tail $mlog > /tmp/nmaserr_detect

function mail_body1() { 
echo "NMAS error -1660 has been detected on $host. Users are not authenticating and have lost access to their data. Please connect to the server and check the status of the novell-cifs daemon (cifsd). It will probably require a restart."
}

# Cat the log extract and and see if we hava NMAS error -1660
/bin/cat /tmp/nmaserr_detect | grep "NMAS has returned Error\:-1660" > /tmp/errdet.1660
if [ -n "$(/bin/cat /tmp/errdet.1660)" ]; then
  if [ -n "$email" ]; then
    mail_body1 | mail -s "NMAS Error -1660 Detected on $host" -a /tmp/errdet.1660 -r $mfrom $email
  fi
else
  echo "NMAS appears to be healthy" > /dev/null
fi

# Cleanup
rm -f /tmp/nmaserr_detect
rm -f /tmp/errdet.1660

exit 1

