#!/bin/bash
#===============================================================================
#
#          FILE: sev_detect.sh
# 
#         USAGE: ./sev_detect.sh
# 
#   DESCRIPTION: Detect SEV maintenance error messages and send email
#
#                Copyright (C) 2015  David Robb
#
#        GPL v3: This program is free software: you can redistribute it and/or 
#                modify it under the terms of the GNU General Public License as
#                published by the Free Software Foundation, either version 3 of
#                the License, or (at your option) any later version.
#
#                This program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty of
#                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                GNU General Public License for more details.
#
#                You should have received a copy of the GNU General Public
#                License along with this program.  If not,
#                see <http://www.gnu.org/licenses/>. 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, drobb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Jan 21 2016 07:30
#  LAST UPDATED: Sun Jun 19 2016 14:29
#      REVISION: 1
#     SCRIPT ID: 067
# SSC UNIQUE ID: ---
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.2
sid=067                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # user checking routine
email=calvin.hamilton@rcmp-grc.gc.ca,david.robb@rcmp-grc.gc.ca     # default email value
log='/var/log/sev_detect.log'                   # logging (if required)
mailc="/tmp/.sev_mailc"                         # only send one email per detection

# Setup the mailcounter
if [ -e /tmp/.sev_mailc ]; then
  echo "mailcounter exists" > /dev/null
else
  touch /tmp/.sev_mailc
  echo "mailed=0" > $mailc
fi

. /tmp/sev_mailc

# Test cifs.log for the existence of SEV messages
tail -n 1 -f /var/log/cifs/cifs.log | while read NEXT_LINE; do
  echo "$NEXT_LINE" | grep 'SEV maintenance: Failed to get effective privileges of user:' > /dev/null 2>&1
  if test $? -eq 0; then
      echo -e "SEV maintenance errors have been detected on $host. This indicates that the recent cifs PTF has not resolved the issue" | mail -s "SEV maintenance erros detected on $host" $email
    exit
  fi
done

