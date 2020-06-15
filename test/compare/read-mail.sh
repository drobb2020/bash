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
#   LAST UDATED: Wed Feb 28 2018 13:44
#       VERSION: 0.1.1
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.0													# version number of the script
sid=000																# personal script ID
uid=00																# SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")								# general date|time stamp
ds=$(date +%a)												# short day of the week eg. Mon
df=$(date +%A)												# long day of the week eg. Monday
host=$(hostname)											# hostname of the local server
fqdn=$(hostname -f)										# fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)												# who is running the script
mfrom=read-mail												# email sender
email=																# email recipient(s)
log='/var/log/read-mail.log'					# log name and location (if required)
#===============================================================================

MAIL_INDEX=$(printf 'h a\nq\n' | mail | egrep -o '[0-9]* unread' | awk '{print $1}')

markAllRead=
for (( i=1; i<=$MAIL_INDEX; i++ ))
do
   markAllRead=$markAllRead"p $i\n"
done
markAllRead=$markAllRead"q\n"
printf "$markAllRead" | mail

echo -e "The accumlated mail in the spool has been read and moved to /$user/mbox. You can read the mail from there."


