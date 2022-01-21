#!/bin/bash - 
#===============================================================================
#
#          FILE: meta-restore.sh
# 
#         USAGE: ./meta-restore.sh 
# 
#   DESCRIPTION: Restore all NSS metadata for the volumes included on the command line
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
#       CREATED: Tue Oct 02 2012 14:34
#  LAST UPDATED: Thu Mar 15 2018 08:34
#       VERSION: 0.1.5
#     SCRIPT ID: 045
# SSC SCRIPT ID: 00
#===============================================================================
host=$(hostname)                                 # hostname of the local server
mfrom=                                           # email sender
email=                                           # email recipient(s)
#===============================================================================

# Command help statement
function helpme() { 
	echo "--[ Help ]--------------------------------------------"
	echo "The correct command line syntax is: "
	echo "./meta-restore.sh <day of the week> VOL1 VOL2 VOL3 ..."
	echo "for example ./meta-restore.sh Tue APPS DATA USER"
	echo "Please remember Pools and Volumes are case-"
	echo "sensitive on Linux."
	echo "======================================================"
	exit 1
}

# Restore NSS Metadata for each volume listed on the command line
if [ $# -lt 1 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  while test -n "$2"
  do
    /sbin/metamig restore "$2" -m a -d < /backup/metadata/"$1"/"$2"
  shift
  done
fi

# mail message
function mail_body1() { 
echo -e "NSS metadata has been restored on $host.\nPlease verify that users still have access to their files."
}

# E-mail results
if [ -n "$email" ]; then
  mail_body1 | mail -s "NSS Metadata Backup log for $host" -r "$mfrom" "$email"
fi

# Finished
exit 1

