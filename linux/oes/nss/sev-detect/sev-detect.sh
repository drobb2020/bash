#!/bin/bash - 
#===============================================================================
#
#          FILE: sev-detect.sh
# 
#         USAGE: ./sev-detect.sh 
# 
#   DESCRIPTION: Detect SEV maintenance error messages and send email
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
#       CREATED: Thu Jan 21 2016 07:30
#  LAST UPDATED: Thu Mar 15 2018 08:43
#       VERSION: 0.1.3
#     SCRIPT ID: 067
# SSC SCRIPT ID: 00
#===============================================================================
host=$(hostname)                                 # hostname of the local server
mfrom=sev-detection                              # email sender
email=root                                       # email recipient(s)
mailc="/tmp/.sev_mailc"                          # only send one email per detection
#===============================================================================

# Setup the mailcounter
if [ -e /tmp/.sev_mailc ]; then
  echo "mailcounter exists" > /dev/null
else
  touch /tmp/.sev_mailc
  echo "mailed=0" > $mailc
fi
. /tmp/sev_mailc

# mail message
function mail_body1() { 
echo -e "SEV maintenance errors have been detected on $host. This indicates that the recent cifs PTF has not resolved the issue"
}

# Test cifs.log for the existence of SEV messages
tail -n 1 -f /var/log/cifs/cifs.log | while read -r NEXT_LINE; do
  echo "$NEXT_LINE" | grep 'SEV maintenance: Failed to get effective privileges of user:' > /dev/null 2>&1
  if test $? -eq 0; then
    mail_body1 | mail -s "SEV maintenance errors detected on $host" -r $mfrom $email
    exit
  fi
done
