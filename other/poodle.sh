#!/bin/bash
#
#  Copyright (C) 2014 by Red Hat
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.

timeout_bin=$(which timeout 2>/dev/null)

# The following ports on the local server may be using SSLv3
echo "The following ports on the server may be using SSLv3"
/bin/netstat -vatn | grep tcp | awk '{ print $4 }' | awk -F: '{ print $NF }' | sort | uniq
echo " "

function helpme() {
	echo "Correct Syntax"
	echo "============================================================"
	echo "The correct commandline syntax is ./poodle.sh <hostname>"
	echo "For example: ./poodle.sh acpic-s779"
	echo "Depending on DNS configuration you may need to use the FQDN."
	echo "------------------------------------------------------------"
}

if [ $# -lt 1 ]
	then 
	  echo "There are not enough arguments on the commandline." > /dev/stderr
	  helpme
	  exit 1
	else
	  echo -n "$1:$2 - "
	  out=$(echo 'Q' | ${timeout_bin:+$timeout_bin 5} openssl s_client -ssl3 -connect "$1:$2" 2>/dev/null)
fi				

if [ $? -eq 124 ]; then
	echo "error: Timeout connecting to host!"
	exit 1
fi

if ! echo "$out" | grep -q 'Cipher is' ; then
	echo 'Not vulnerable.  Failed to establish SSL connection.'
	exit 0
fi

proto=$(echo "$out" | grep '^ *Protocol *:' | awk '{ print $3 }')
cipher=$(echo "$out" | grep '^ *Cipher *:' | awk '{ print $3 }')

if [ "$cipher" = '0000' ] || [ "$cipher" = '(NONE)' ]; then
	echo 'Not vulnerable.  Failed to establish SSLv3 connection.'
	exit 0
else
	echo "Vulnerable!  SSLv3 connection established using $proto/$cipher"
	exit 1
fi

