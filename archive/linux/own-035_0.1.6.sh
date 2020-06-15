#!/bin/bash - 
#===============================================================================
#
#          FILE: own
# 
#         USAGE: ./own <new owner> <new group> <current owner>
# 
#   DESCRIPTION: Take ownership of any file by supplying the username of the account you want to be owner and the current owner account name
#
#                Copyright (C) 2016  David Robb
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
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Sat Jun 11 2016 16:54
#  LAST UPDATED: Sun Jun 19 2016 13:51
#      REVISION: 5
#     SCRIPT ID: 035
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.6
sid=035                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
group=                                          # group the new owner is a member of
email=root                                      # who to send email to (comma separated list)
log='/var/log/own.log'                          # logging (if required)

function helpme() { 
  echo "---------------------------------------------------------------------------"
  echo "The correct command line syntax is ./own new owner current_owner"
  echo "for example: ./own a00212363 root"
  echo "---------------------------------------------------------------------------"
  exit 1
}

CWD=$(pwd)

if [ $# -lt 2 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  /usr/bin/find $CWD -user $2 -exec chown -Rv $1.$group {} \;
fi

exit 1

