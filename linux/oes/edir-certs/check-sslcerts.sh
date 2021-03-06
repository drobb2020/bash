#!/bin/bash - 
#===============================================================================
#
#          FILE: check-sslcerts.sh
# 
#         USAGE: ./check-sslcerts.sh 
# 
#   DESCRIPTION: Check for expired SSL Certificates for the OES Servers in the CAS-SAC Tree
#
#                Copyright (c) 2017, David Robb
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
#       CREATED: Thu Dec 14 2017 11:56
#  LAST UPDATED: Thu Dec 14 2017 
#       VERSION: 0.1.0
#     SCRIPT ID: 000
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.0				# version number of the script
sid=000					# personal script ID
uid=00					# SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")			# general date|time stamp
ds=$(date +%a)				# short day of the week eg. Mon
df=$(date +%A)				# long day of the week eg. Monday
host=$(hostname)			# hostname of the local server
fqdn=$(hostname -f)			# fully qualified host name of local server
ip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127 # local IP Addr)
user=$(whoami)				# who is running the script
email=					# email recipient(s)
log='/var/log/check-sslcerts.log'	# log name and location (if required)
#===============================================================================

function certsnow() { 
/opt/novell/eDirectory/bin/ldapsearch -x -l 15 -b o=rcmp-grc -s sub -h 10.4.32.247 'objectclass=nDSPKIKeyMaterial' nDSPKINotAfter >> certs_before.txt
echo "Type the year and month that you want to check for expiring certificates in the format YYYYMM eg. 201801, followed by [ENTER]:"
read yearmonth
cat certs_before.txt | grep "$yearmonth" -B 4 | grep "SSL CertificateDNS" | grep dn | cut -f 2- -d "-" >> expiring_certs.txt
}

function certsafter() {
/opt/novell/eDirectory/bin/ldapsearch -x -l 15 -b o=rcmp-grc -s sub -h 10.4.32.247 'objectclass=nDSPKIKeyMaterial' nDSPKINotAfter >> certs_after.txt
}

selection=
until [ "selection" = "0" ]; do
	echo ""
	echo "Check for Expired SSL Certificates in the CAS-SAC Tree"
	echo "======================================================"
	echo "1 - Check for expiring certificates"
	echo "2 - Verify all certificates are valid"
	echo "0 - exit"
	echo ""
	echo -n "Enter selection: "
	read selection
	echo ""
	case $selection in
		1 ) echo -e "Checking for expired or expiring certs (30 days)." ; certsnow ;;
		2 ) echo -e "Verifing all certs are valid." ; certsafter ;;
		0 ) exit ;;
		* ) echo "Please enter 1, 2, or 0" ;;
	esac
done

exit 1

