#!/bin/bash - 
#===============================================================================
#
#          FILE: tcksupdate.sh
# 
#         USAGE: ./tcksupdate.sh alias /path/to/certificate
# 
#   DESCRIPTION: Script to update the Tomcat5 certificate keystore
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David Robb (der), drobb@novell.com
#  ORGANIZATION: Novell
#       CREATED: 03/04/2013 11:55:53 AM EST
#      REVISION: 0.1-01
#===============================================================================

set -o nounset                              # Treat unset variables as an error
ID=$(whoami)

# Check if the user is root
if [ $ID != "root" ]
    then
			echo "You must be root to run this script. Exiting ..."
			exit
fi

function helpme() {	
	echo "The correct command line syntax is ./tcksupdate.sh alias /path/to/certificate"
	echo "For example: ./tcksupdate.sh atlantic_CA /tmp/RootCert-ATL.der"
	echo "         or, ./tcksupdate.sh anhq-s196 /tmp/anhq-s196.der"
	exit 1
}

if [ $# -lt 2 ]
	then
		echo "There are not enough arguments on the command line." > /dev/stderr
		helpme
	else
		keytool -import -alias $1 -file $2 -keystore /var/opt/novell/tomcat5/conf/cacerts
fi

exit

