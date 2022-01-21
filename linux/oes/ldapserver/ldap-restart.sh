#!/bin/bash

# Simple script to stop and restart nldap to see if the certs are still present
log=/root/ldap-restart-test.log
rm -r /root/ldap-restart-test.log
touch /root/ldap-restart-test.log

# Get the current PID of ndsd
pn0=$(/bin/pidof /opt/novell/eDirectory/sbin/ndsd)
echo "The PID of NDSD is: ${pn0}" | tee -a $log
echo "" | tee -a $log

# Run top to check the current load on ndsd
echo "Run top to see what the current load on ndsd is." | tee -a $log
echo "Check $log to see the results." | tee -a $log
/usr/bin/timeout 5s /usr/bin/top -b -n 1 -p "$pn0" | tee -a $log
clear

# Check that ldap is listening on both 389 and 636
echo "Make sure LDAP is currently listening on both ports." | tee -a $log
/bin/netstat -na | grep LISTEN | grep -E "389|636" | grep -v unix | tee -a $log
echo "" | tee -a $log

# Check the KMO expiration date
echo "Check to make sure the SSL Certificates assigned to the server are valid." | tee -a $log
/opt/novell/eDirectory/bin/ldapsearch -x -l 15 -h 10.4.9.174 -b "" -s sub '(&(objectClass=nDSPKIKeymaterial)(hostserver=cn=acpic-s3908,ou=IDM-NATL,o=PAC))' nDSPKINotAfter | tee -a $log
echo "" | tee -a $log

# Stop nldap
echo "Stopping nldap (nldap -u)" | tee -a $log
/opt/novell/eDirectory/sbin/nldap -u | tee -a $log
sleep 5
echo "" | tee -a $log

# Start nldap
echo "Starting nldap (nldap -l)" | tee -a $log
/opt/novell/eDirectory/sbin/nldap -l | tee -a $log
echo "" | tee -a $log

# Check that nldap is listening on 389 and 636
echo "Check to see that nldap is listening on both ports" | tee -a $log
/opt/novell/eDirectory/sbin/nldap_check | tee -a $log
echo "" | tee -a $log

# Get the new PID of ndsd
pn1=$(/bin/pidof /opt/novell/eDirectory/sbin/ndsd)
echo "The PID of ndsd is: ${pn1}" | tee -a $log
echo "" | tee -a $log

# Run top again to see the load on ndsd
echo "Run top again to verify the load on ndsd" | tee -a $log
echo "Check $log to see the results." | tee -a $log
/usr/bin/timeout 5s /usr/bin/top -b -n 1 -p "$pn1" | tee -a $log
clear

sleep 5

# is ldap still listening
echo "Check that ldap is listening for connections." | tee -a $log
/bin/netstat -na | grep LISTEN | grep -E "389|636" | grep -v unix | tee -a $log
clear

echo ""
echo "Please review the log file generated for this operation at: $log"

#finished
exit 0
