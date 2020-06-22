#!/bin/bash - 
#===============================================================================
#
#          FILE: updateBanner.sh
# 
#         USAGE: ./updateBanner.sh
# 
#   DESCRIPTION: Script to update the static sshd-banner file
#
#                Copyright (C) 2015  David Robb
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
#       OPTIONS: 
#  REQUIREMENTS: Script needs to be run whenever the kernel changes
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus
#       CREATED: Fri Dec 18 2015 14:13
#  LAST UPDATED: Wed Jul 27 2016 09:19
#      REVISION: 2
#     SCRIPT ID: 098
#===============================================================================
set -o nounset                                    # Treat unset variables as an error
version=0.1.2                                     # version
sid=098                                           # script ID number
ts=$(date +"%b %d %T")                            # general date/time stamp
host=$(hostname)                                  # host name of local server
user=$(whoami)                                    # user checking routine
org='Excession Systems Research and Development Environment'    # Organization name
admin=david.robb@excession.org                    # e-mail address of designated administrator
dse=david.robb@microfocus.com                     # e-mail address of Dedicated support Engineer
log='/var/log/updateBanner.log'                   # logging (if required)
sn=$(cat /etc/SuSE-release | grep SUSE)
sv=$(cat /etc/SuSE-release | grep VERSION | awk '{print $NF}')
sp=$(cat /etc/SuSE-release | grep PATCHLEVEL | awk '{print $NF}')
sr="$sn $sv.$sp"

if [ -f /etc/novell-release ]; then
  on=$(cat /etc/novell-release | grep Novell)
  ov=$(cat /etc/novell-release | grep VERSION | awk '{print $NF}')
  or="$on $ov"
else
  echo "OES is not installed or configured on this server" > /dev/null
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
  if [ "$sf" == "$sr" ]; then
    echo "OS strings match"
  else
    sed -i "s/$sf/$sr/g" /etc/ssh/sshd-banner
  fi
else
  echo "OS not included in sshd-banner"
fi

if [ -f "/etc/novell-release" ]; then 
  if [ -n "cat /etc/ssh/sshd-banner | grep OES" ]; then
    of=$(cat /etc/ssh/sshd-banner | grep OES | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
    if [ "$of" = "$or" ]; then
      echo "OES strings match"
    else
      sed -i "s/$of/$or/g" /etc/ssh/sshd-banner
    fi
  else
    echo "OES not included in sshd-banner"
  fi
else
  echo "OES is not installed or configured on this server"
fi

#finished
exit 1

