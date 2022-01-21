#!/bin/bash - 
#===============================================================================
#
#          FILE: read-mail.sh
# 
#         USAGE: ./read-mail.sh 
# 
#   DESCRIPTION: parse through all the messages in /var/spool/mail/<user>
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
#       CREATED: Wed Feb 28 2018 13:38
#  LAST UPDATED: Wed Sep 01 2021  12:46
#       VERSION: 0.1.2
#     SCRIPT ID: 000
#===============================================================================
user=$(whoami)												# who is running the script
#===============================================================================

MAIL_INDEX=$(printf 'h a\nq\n' | mail | grep -Eo '[0-9]* unread' | awk '{print $1}')

markAllRead=
for (( i=1; i<="$MAIL_INDEX"; i++ ))
do
   markAllRead=$markAllRead"p $i\n"
done
markAllRead=$markAllRead"q\n"
printf "%s" "$markAllRead" | mail

echo -e "The accumulated mail in the spool has been read and moved to /$user/mbox. You can read the mail from there."

exit 0
