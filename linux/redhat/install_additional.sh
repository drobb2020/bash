#!/bin/bash
#===============================================================================
#
#    FILE: install.sh
#
#    USAGE: ./install_additional.sh (RedHat 6.x Only)
#
#    DESCRIPTION: Install additional dependency packages for iManager,
#                 IDM, and Access Manager
#
#    Copyright (C) 2020  David Robb
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS:
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Tuesday Aug 04 2020 17:05
#  LAST UPDATED: Thursday Aug 13 2020 15:56
#       VERSION: 0.1.2
#     SCRIPT ID: 00x
#===============================================================================
# Check OS version, if not RHEL quit!
# OS=$(cat /etc/redhat-release | grep -w 'Red Hat' | awk 'NR==1{ print $1,$2 }' | sed s'/ //g')
OS=$(/usr/bin/lsb_release -a | grep RedHat | cut -f 2)
VER=$(/usr/bin/lsb_release -a | grep Description | cut -f 2)
if  [ "$OS" = RedHatEnterpriseServer ]; then
    echo "You are running: $VER."
    echo "Continuing..."
else
    echo "This is not a Red Hat Server, no need to run this script."
    echo "Exiting without making any changes."
    sleep 10
    exit 0
fi

# Clean the local repos for Red Hat
yum clean all
yum repolist
yum makecache

# Packages for iManager
PKGSIM="glibc.i686 libstdc++.i686 libstdc++.x86_64 libXau.x86_64 libxcb.x86_64 
libX11.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 libxcb.i686 libX11.i686 
libXtst.i686 libXrender.i686"

# Packages for Identity Manager
PKGSIDM="ksh gettext.x86_64 libXrender.i686 libXau.i686 libxcb.i686 libX11.i686
libXext.i686 libXi.i686 libXtst.i686 glibc.x86_64 libstdc++.i686
libstdc++.x86_64 libgcc.x86_64 compat-libstdc++-33.x86_64"

# Packages for Access Manager Administration Console
PKGSAC="gettext.x86_64 glibc.i686 libstdc++.i686 ncurses-libs.i686 libgcc.i686 
rsyslog.x86_64 rsyslog-gnutls.x86_64 binutils.x86_64 gperftools-libs.x86_64"

# Packages for Identity Server
PKGSIS="glibc.i686 libstdc++.i686 ncurses-libs.i686 libgcc.i686 rsyslog.x86_64 
rsyslog-gnutls.x86_64 binutils.x86_64"

# Packages for Access Gateway
PKGSAG="glibc.i686 db4.x86_64 apr.x86_64 apr-util.x86_64 libtool-ltdl.x86_64 
unixODBC.x86_64 libesmtp.x86_64 rsyslog.x86_64 rsyslog-gnutls.x86_64 
binutils.x86_64 patch.x86_64"

# Menu
while [ answer != "0" ] 
do
    clear
    echo "-------------------------------------------------------------------"
    echo "Red Hat Dependency Libraries Install for NetIQ Software"
    echo "-------------------------------------------------------------------"
    echo "1     Additional packages for iManager"
    echo "2     Additional packages for IDM"
    echo "3     Additional packages for Access Manager Administration Console"
    echo "4     Additional packages for Access Manager Identity Server"
    echo "5     Additional packages for Access Manager Access Gateway"
    echo "0     Exit"
    read -r -p "  ?: " answer
    case $answer in
       0) break ;;
       1) echo "iManager Packages"
            for PKG in $PKGSIM;
                do
                yum -y install "$PKG"
                done
        ;;
        2) echo "Identity Manager Packages"
            for PKG in $PKGSIDM;
                do
                yum -y install "$PKG"
                done
        ;;
        3) echo "AM Administration Console"
            for PKG in $PKGSAC;
                do
                yum -y install "$PKG"
                done
        ;;
        4) echo "AM Identity Server"
            for PKG in $PKGSIS;
                do
                yum -y install "$PKG"
                done
        ;;
        5) echo "AM Access Gateway"
            for PKG in $PKGSAG;
                do
                yum -y install "$PKG"
                done
        ;;
        *) echo "You must select between 1 and 5, try again."; break ;;
    esac 
   echo "press ENTER for menu"
   read -r key
done
