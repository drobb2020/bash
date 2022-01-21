#!/bin/bash - 
#===============================================================================
#
#          FILE: tcksupdate6.sh
# 
#         USAGE: ./tcksupdate6.sh cert_alias /path/to/certificate
# 
#   DESCRIPTION: update the Tomcat6 certificate keystore
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
#       CREATED: Wed Apr 03 2013 11:55
#  LAST UPDATED: Tue Aug 31 2021 10:39
#       VERSION: 0.1.4
#     SCRIPT ID: 085
# SSC SCRIPT ID: 00
#===============================================================================

# Who is running this script - you must be root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script as root"
  exit 1
fi

# Commandline help
function helpme() {	
	echo "The correct command line syntax is ./tcksupdate.sh alias /path/to/certificate"
	echo "For example: ./tcksupdate.sh atlantic_CA /tmp/RootCert-ATL.der"
	echo "         or, ./tcksupdate.sh anhq-s196 /tmp/anhq-s196.der"
	exit 1
}

# Check for commandline values and run keytool
if [ $# -lt 2 ]
	then
		echo "There are not enough arguments on the command line." > /dev/stderr
		helpme
	else
		keytool -import -alias "$1" -file "$2" -keystore /var/opt/novell/tomcat6/conf/cacerts
fi

# Finished
exit 0
