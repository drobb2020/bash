#!/bin/bash - 
#===============================================================================
#
#          FILE: repo-update.sh
# 
#         USAGE: ./repo-update.sh 
# 
#   DESCRIPTION: Automatically add the correct repositories for OES11 SP1 or OES11 SP2
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
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Jan 27 2015 10:15
#  LAST UPDATED: Wed Jul 22 2015 14:14
#      REVISION: 3
#     SCRIPT ID: 056
# SSC SCRIPT ID: ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.3
sid=056                                     # personal script id number
uid=00                                      # SSC/RCMP script id number
ts=$(date +"%b %d %T")                      # general date/time stamp
ds=$(date +%a)                              # breviated day of the week, eg Mon
df=$(date +%A)                              # full day of the week, eg Monday
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/repo-update.log'              # logging (if required)

oesver=$(cat /etc/novell-release | grep VERSION | awk '{print $NF}')
tree=$(ndsconfig get | grep n4u.base.tree-name | cut -f 2 -d"=")

if [ "$tree" = CAS-DEV ]; then
  # Update the repos on CAS-DEV servers so they point to acpic-s2860
  if [ "$oesver" = 11.2 ]; then
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/OES11-SP2-Pool/sle-11-x86_64 CAS-DEV-OES11-SP2-Pool
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/OES11-SP2-Updates/sle-11-x86_64 CAS-DEV-OES11-SP2-Updates
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLES11-SP3-Pool/sle-11-x86_64 CAS-DEV-SLES11-SP3-Pool
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLES11-SP3-Updates/sle-11-x86_64 CAS-DEV-SLES11-SP3-Updates
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLE11-SDK-SP3-Pool/sle-11-x86_64 CAS-DEV-SLE11-SDK-SP3-Pool
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLE11-SDK-SP3-Updates/sle-11-x86_64 CAS-DEV-SLE11-SDK-SP3-Updates
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/install/oes11sp2 SLES11-SP3-Install
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/install/sle11sdksp3 SLE11-SDK-SP3-Install
  else
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/OES11-SP1-Pool/sle-11-x86_64 CAS-DEV-OES11-SP1-Pool
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/OES11-SP1-Updates/sle-11-x86_64 CAS-DEV-OES11-SP1-Updates
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLE11-SDK-SP2-Core/sle-11-x86_64 CAS-DEV-SLE11-SDK-SP2-Core
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLE11-SDK-SP2-Updates/sle-11-x86_64 CAS-DEV-SLE11-SDK-SP2-Updates
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLES11-SP2-Core/sle-11-x86_64 CAS-DEV-SLES11-SP2-Core
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/updates/SLES11-SP2-Updates/sle-11-x86_64 CAS-DEV-SLES11-SP2-Updates
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/install/oes11sp1 SLES11-SP2-Install
    /usr/bin/zypper ar -f http://acpic-s2860.ross.rossdev.rcmp-grc.gc.ca/install/sle11sdksp2 SLE11-SDK-SP2-Install
  fi
else
  if [ "$oesver" = 11.2 ]; then
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/OES11-SP2-Pool/sle-11-x86_64 CAS-SAC-OES11-SP2-Pool
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/OES11-SP2-Updates/sle-11-x86_64 CAS-SAC-OES11-SP2-Updates
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLES11-SP3-Pool/sle-11-x86_64 CAS-SAC-SLES11-SP3-Pool
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLES11-SP3-Updates/sle-11-x86_64 CAS-SAC-SLES11-SP3-Updates
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLE11-SDK-SP3-Pool/sle-11-x86_64 CAS-SAC-SLE11-SDK-SP3-Pool
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLE11-SDK-SP3-Updates/sle-11-x86_64 CAS-SAC-SLE11-SDK-SP3-Updates
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/install/oes11sp2 SLES11-SP3-Install
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/install/sle11sdksp3 SLE11-SDK-SP3-Install
  else
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/OES11-SP1-Pool/sle-11-x86_64 CAS-SAC-OES11-SP1-Pool
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/OES11-SP1-Updates/sle-11-x86_64 CAS-SAC-OES11-SP1-Updates
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLE11-SDK-SP2-Core/sle-11-x86_64 CAS-SAC-SLE11-SDK-SP2-Core
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLE11-SDK-SP2-Updates/sle-11-x86_64 CAS-SAC-SLE11-SDK-SP2-Updates
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLES11-SP2-Core/sle-11-x86_64 CAS-SAC-SLES11-SP2-Core
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/updates/SLES11-SP2-Updates/sle-11-x86_64 CAS-SAC-SLES11-SP2-Updates
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/install/oes11sp1 SLES11-SP2-Install
    /usr/bin/zypper ar -f http://acpic-s2657.ross.rcmp-grc.gc.ca/install/sle11sdksp2 SLE11-SDK-SP2-Install
  fi
fi

exit 1

