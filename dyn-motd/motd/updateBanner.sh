#!/bin/bash - 
#===============================================================================
#
#          FILE: updateBanner.sh
# 
#         USAGE: ./updateBanner.sh 
# 
#   DESCRIPTION: Script to update the static sshd-banner file
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
#       CREATED: Fri Dec 18 2015 14:13
#  LAST UPDATED: Sun Jun 19 2016 14:02
#      REVISION: 3
#     SCRIPT ID: 066
# SSC UNIQUE ID: --
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.3                                   # version number of the script
sid=066                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
org='Excession Systems Production Environment'  # Organization name
admin=david.robb@excession.org                  # e-mail address of designated administrator
dse=david.robb@microfocus.com                   # e-mail address of Dedicated support Engineer
email=root                                      # who to send email to (comma separated list)
log='/var/log/updateBanner.log'                 # logging (if required)
# sn=$(cat /etc/SuSE-release | grep SUSE)
# sv=$(cat /etc/SuSE-release | grep VERSION | awk '{print $NF}')
# sp=$(cat /etc/SuSE-release | grep PATCHLEVEL | awk '{print $NF}')
# sr="$sn $sv.$sp"
sr=$(cat /etc/os-release | grep PRETTY_NAME | cut -f 2 -d '=' | sed -e 's/^"//' -e 's/"$//')

if [ -f /etc/novell-release ]; then
  on=$(cat /etc/novell-release | grep Novell)
  ov=$(cat /etc/novell-release | grep VERSION | awk '{print $NF}')
  or="$on $ov"
else
  echo "OES not installed or configured on this server"
fi

if [ -f /etc/ssh/sshd-banner ]; then
  echo "Proceed with editing the banner" > /dev/null
else
  echo "The sshd-banner file does not exist, please configure the server and try again."
  exit 1
fi

if [ -n "cat /etc/ssh/sshd-banner | grep Kernel" ]; then
  kf=$(cat /etc/ssh/sshd-banner | grep Kernel | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  kr=$(uname -r)
  # echo "Kernel in banner is $kf"
  # echo "Running Kernel is $kr"
  if [ $kf = $kr ]; then
    echo "Kernel versions match"
  else
    sed -i "s/$kf/$kr/g" /etc/ssh/sshd-banner
  fi
else
  echo "Kernel not included in sshd-banner"
fi

if [ -n "cat /etc/ssh/sshd-banner | grep Host" ]; then
  hf=$(cat /etc/ssh/sshd-banner | grep Host | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  hr=$host
  # echo "Host in banner is $hf"
  # echo "Actual host name is $hr"
  if [ $hf = $hr ]; then
    echo "host names match"
  else
    sed -i "s/$hf/$hr/g" /etc/ssh/sshd-banner
  fi
else
  echo "Host not included in sshd-banner"
fi

if [ -n "cat /etc/ssh/sshd-banner | grep OS" ]; then
  sf=$(cat /etc/ssh/sshd-banner | grep OS | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  # echo "The OS string is $sr"
  if [ "$sf" = "$sr" ]; then
    echo "OS strings match"
  else
    sed -i "s/$sf/$sr/g" /etc/ssh/sshd-banner
  fi
else
  echo "OS not included in sshd-banner"
fi

if [ -n "cat /etc/ssh/sshd-banner | grep OES" ]; then
  of=$(cat /etc/ssh/sshd-banner | grep OES | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  # echo "The OES string is $or"
  if [ "$of" = "$or" ]; then
    echo "OES strings match"
  else
    sed -i "s/$of/$or/g" /etc/ssh/sshd-banner
  fi
else
  echo "OES not included in sshd-banner"
fi

exit 1

