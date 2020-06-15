#!/bin/bash - 
#===============================================================================
#
#          FILE: own
# 
#         USAGE: ./own <new owner> <current owner>
# 
#   DESCRIPTION: Take ownership of any file by supplying the username of the 
#                account you want to be owner and the current owner account name
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
#       CREATED: Sat Jun 11 2016 16:54
#   LAST UDATED: Thu Mar 15 2018 07:44
#       VERSION: 0.1.7
#     SCRIPT ID: 035
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.7                                    # version number of the script
sid=035                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=ownership                                  # email sender
email=root                                       # email recipient(s)
log='/var/log/own.log'                           # log name and location (if required)
group=                                           # group the new owner is a member of
#===============================================================================

# command syntax help
function helpme() { 
  echo "---------------------------------------------------------------------------"
  echo "The correct command line syntax is ./own new owner current_owner"
  echo "for example: ./own a00212363 root"
  echo "---------------------------------------------------------------------------"
  exit 1
}

# work on files in the current working directory
cwd=$(pwd)

if [ $# -lt 2 ]; then
  echo "There are not enough arguments on the command line." > /dev/stderr
  helpme
else
  /usr/bin/find $cwd -user $2 -exec chown -Rv $1.$group {} \;
fi

exit 1

