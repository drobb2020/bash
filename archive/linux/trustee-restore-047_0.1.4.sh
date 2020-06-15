#!/bin/bash - 
#===============================================================================
#
#          FILE: trustee-restore.sh
# 
#         USAGE: ./trustee-restore.sh 
# 
#   DESCRIPTION: Restore NSS Trustee data for a volume. 
#                This is not the same as using metamig!
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
#       CREATED: Tue Jul 21 2015 14:38
#   LAST UDATED: Thu Mar 15 2018 08:57
#       VERSION: 0.1.4
#     SCRIPT ID: 047
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.4                                    # version number of the script
sid=047                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=trustee-restore                            # email sender
email=root                                       # email recipient(s)
log='/var/log/trustee-restore.log'               # log name and location (if required)
#===============================================================================

# command help statement
function helpme() { 
  echo "--[ Help ]------------------------------------"
  echo "The correct command line syntax is: "
  echo "./trustee-restore.sh <day of week> VOL1"
  echo "for example ./trustee-restore.sh Tuesday DATA"
  echo "Please remember Volumes are case-sensitive"
  echo "on Linux."
  echo "=============================================="
  exit 1
}

# trustee restore
if [ $# -lt 2 ]; then
  echo "There are not enough options on the command line" >> /dev/stderr
  helpme
else
	/bin/zTrustee /R ALL RESTORE ALL /backup/$host/trustee/$1/$2-backup
fi

exit 1

