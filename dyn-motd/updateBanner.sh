#!/bin/bash - 
#===============================================================================
#
#          FILE: updateBanner.sh
# 
#         USAGE: ./updateBanner.sh
# 
#   DESCRIPTION: Script to update the static sshd_banner file
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
#  LAST UPDATED: Fri Aug 04 2017 11:35
#      REVISION: 5
#     SCRIPT ID: 098
#===============================================================================
# set -o nounset                                  # Treat unset variables as an error
version=0.1.5                                     # version
sid=098                                           # script ID number
ts=$(date +"%b %d %T")                            # general date/time stamp
host=$(hostname)                                  # host name of local server
user=$(whoami)                                    # user checking routine
org='Excession Systems Production Network'        # Organization name
admin=david.robb@excession.org                    # e-mail address of designated administrator
dse=david.robb@microfocus.com                     # e-mail address of Dedicated support Engineer
log='/var/log/updateBanner.log'                   # logging (if required)

# Rename the sshd-banner file
bn=$(ls /etc/ssh/ | grep sshd-)
if [ -z $bn ]; then
  echo ">> The old banner name does not exist"
else
  mv /etc/ssh/sshd-banner /etc/ssh/sshd_banner
  br1=$(cat /etc/ssh/sshd_config | grep sshd-banner | awk '{ print $NF }' | cut -f 4 -d'/')
  sed -i 's/'"$br1"'/sshd_banner/g' /etc/ssh/sshd_config
  /etc/init.d/sshd restart
fi

# Get server release from os-releae file (new)
sr=$(cat /etc/os-release | grep PRETTY_NAME | cut -f 2- -d '=' | sed -e 's/^"//' -e 's/"$//')

# Get oes release if this is an OES server
if [ -f /etc/novell-release ]; then
  on=$(cat /etc/novell-release | grep Novell)
  ov=$(cat /etc/novell-release | grep VERSION | awk '{print $NF}')
  or="$on $ov"
else
  echo ">> OES is not installed or configured on this server" > /dev/null
fi

#Make sure the sshd_banner file is in the correct location
if [ -f /etc/ssh/sshd_banner ]; then
  echo ">> Proceed with editing the banner" > /dev/null
else
  echo ">> The sshd_banner file does not exist, please configure the server and try again."
  exit 1
fi

# Update the Kernel build number in the banner
if [ -n "cat /etc/ssh/sshd_banner | grep Kernel" ]; then
  kf=$(cat /etc/ssh/sshd_banner | grep Kernel | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  kr=$(uname -r)
  if [ $kf = $kr ]; then
    echo ">> Kernel versions match"
  else
    sed -i "s/$kf/$kr/g" /etc/ssh/sshd_banner
    echo ">> Kernel version updated in ssh banner"
  fi
else
  echo ">> Kernel not included in sshd_banner"
fi

# Update the host name of the serve in the banner
if [ -n "cat /etc/ssh/sshd_banner | grep Host" ]; then
  hf=$(cat /etc/ssh/sshd_banner | grep Host | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  hr=$host
  if [ $hf = $hr ]; then
    echo ">> Host names match"
  else
    sed -i "s/$hf/$hr/g" /etc/ssh/sshd_banner
    echo ">> Host name updated in ssh banner"
  fi
else
  echo ">> Host not included in sshd_banner"
fi

# Update the OS version in the banner
if [ -n "cat /etc/ssh/sshd_banner | grep OS" ]; then
  sf=$(cat /etc/ssh/sshd_banner | grep OS | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
  if [ "$sf" == "$sr" ]; then
    echo ">> OS strings match"
  else
    sed -i "s/$sf/$sr/g" /etc/ssh/sshd_banner
    echo ">> OS version updated in ssh banner"
  fi
else
  echo ">> OS not included in sshd_banner"
fi

# Update the OES version in the banner (if installed)
if [ -f "/etc/novell-release" ]; then 
  if [ -n "cat /etc/ssh/sshd_banner | grep OES" ]; then
    of=$(cat /etc/ssh/sshd_banner | grep OES | cut -f2 -d ":" | sed -e 's/^[ \t]*//')
    if [ "$of" = "$or" ]; then
      echo ">> OES strings match"
    else
      sed -i "s/$of/$or/g" /etc/ssh/sshd_banner
      echo ">> OES version updated in ssh banner"
    fi
  else
    echo ">> OES not included in sshd_banner"
  fi
else
  echo ">> OES is not installed or configured on this server"
fi

#finished
exit 1

