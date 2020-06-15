#!/bin/bash - 
#===============================================================================
#
#          FILE: edirhealth.sh
# 
#         USAGE: ./edirhealth.sh 
# 
#   DESCRIPTION: Script to check nds health on the local server
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
#       CREATED: Wed Oct 02 2013 13:04
#   LAST UDATED: Tue Mar 13 2018 10:24
#       VERSION: 0.1.4
#     SCRIPT ID: 026
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.4                                    # version number of the script
sid=026                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=eDirectoroy-health                         # email sender
email=root                                       # email recipient(s)
log='/var/log/edirhealth.log'                    # log name and location (if required)
ndsbin=/opt/novell/eDirectory/bin                # Path to nds binaries
ndsconf=/etc/opt/novell/eDirectory/conf/nds.conf # Path to nds configuration files
fn=$host$df                                      # Name for eDirectory health report
adm=admin.rnd                                    # Administrator's account name
#===============================================================================

# Create folder to store report
if [ -d /backup/$host/health ]; then
  echo "Directory exists, continuing ..." >> /dev/null
else
  /bin/mkdir -p /backup/$host/health
fi

# Run ndscheck
$ndsbin/ndscheck -a $adm -F /backup/$host/health/$fn -W -q --config-file $ndsconf

function mail_body1() { 
echo -e "Please find attached the eDirectory health check for $host. Please investigate and remedy any errors noted."
}

# E-mail the results
if [ -n "$email" ]; then
  mail_body1 | mail -s "eDirectory Health Check for $host" -r $mfrom $email < /backup/$host/health/$fn
fi

# Finished
exit 1

