#!/bin/bash
REL=0.1-2
SID=053
##############################################################################
#
#    repo-update.sh - Script to automatically add the correct repositories for
#                     OES11 SP1 or OES11 SP2
#    Copyright (C) 2015  David Robb
#
##############################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Authors/Contributors:
#       David Robb (drobb@novell.com)
#
##############################################################################
# Date Created: Tue Jan 27 10:15:28 2015 
# Last updated: Thu May 28 09:40:22 2015 
# Crontab command: not recommended
# Supporting file: None
# Additional notes: 
##############################################################################
TS=$(date +'%b %d %T')
HOST=$(hostname)
USER=$(whoami)
EMAIL=root
OESVER=$(cat /etc/novell-release | grep VERSION | awk '{print $NF}')
TREE=$(ndsconfig get | grep n4u.base.tree-name | cut -f 2 -d"=")

if [ "$TREE" = CAS-DEV ]; then
  # Update the repos on CAS-DEV servers so they point to acpic-s2860
  if [ "$OESVER" = 11.2 ]; then
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
  if [ "$OESVER" = 11.2 ]; then
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



