#!/bin/bash
# Author: David Robb
# Version: 1.9.1
# Date created: March 10, 2011
# Last updated: Tue Jan 31 10:26:07 EST 2012 
# Company: Novell Inc.
# Purpose of Script: To generate a report on the slp registrations on a server. Similar to display slp services on NetWare.
# Crontab command: Not recommended
# Supporting file: /tmp/slphealthmessage.txt
# Remember to set the custom variables for your environment

# Declare variables
HOST=$(hostname)
TODAY=$(date +"%b-%d-%Y")
WHO=$(whoami)

# Custom variables
REPDIR=/root/reports
REPNAME=slpServices-$HOST-$TODAY.txt
TMPDIR=/tmp
TMPREP=slpServices.txt
INCDIR=/root/bin
EMAIL=edirreports@excs2net.org
HEADER="--------------------------------------------------------------------------"
FOOTER="=========================================================================="
REPHEADER="################ Report Date: $(date +"%a, %b %d, %Y -%l:%M %p") ################"
REPHOST="###################### Reported From: $HOST ######################"

# LDAP Variables
# Common
PORT=389
STYPE=sub

# Tree1
TREE1=EXCS2-TREE
HOSTIP1=192.168.0.170
NAME1="cn=admin,ou=servers,ou=services,o=excs2"
PW1=nashira!=000
BASE1=o=excs2

# Tree2
TREE2=EXCS-TREE
HOSTIP2=192.168.0.131
NAME2="cn=admin,o=excs"
PW2=nashira!=000
BASE2=o=excs

# SSH Variables
# Common
SSH_PORT=22
# openSLP Server1
SSH_HOST1=excs-ott-006.excession.org
# openSLP Server2
SSH_HOST2=

# Functions
addspace() { echo "" >> $REPDIR/$REPNAME 
}
addheader() { echo $HEADER >> $REPDIR/$REPNAME
addspace
}
addfooter() { 
addspace
echo $FOOTER >> $REPDIR/$REPNAME 
}
addrephost() { echo $REPHOST >> $REPDIR/$REPNAME 
addspace 
}
addrepheader() { echo $REPHEADER >> $REPDIR/$REPNAME 
addrephost 
}

#Check if user is root
if [ $WHO != "root" ];then

	echo 'You ust be root to run this script, exiting. . .'
	exit
fi

# Check that Reports Directory exists
if [ ! -e $REPDIR ];then
	
	mkdir $REPDIR
fi

# Delete the last report
if [ -e $REPDIR/slpServices-*.txt ]
		then
		/bin/rm $REPDIR/slpServices*.txt
		else
				echo "Old report does not exist, continuing..."
fi

# Run an ldapsearch to get the records from eDirectory
ldapsearch -x -h $HOSTIP1 -p $PORT -D $NAME1 -w $PW1 -b $BASE1 -s $STYPE "(objectClass=sLPService)" >> /tmp/edir1.txt
ldapsearch -x -h $HOSTIP2 -p $PORT -D $NAME2 -w $PW2 -b $BASE2 -s $STYPE "(objectClass-sLPService)" >> /tmp/edir2.txt

# Create a new report and set the date-timestamp at the top
addrepheader
addfooter
echo "Service Registrations:" >> $REPDIR/$REPNAME
addheader

# Generate a list of slp services
/usr/bin/slptool findsrvtypes > /tmp/list.txt

# Loop through and run slptool for each service type and write each iteration to a temporary report
for srvtype in $(cut -f 1 /tmp/list.txt)
do
	/usr/bin/slptool findsrvs $srvtype >> $TMPDIR/$TMPREP
done

# Loop through and run slptool for each service type and write each iteration to the final report
for srvtype in $(cut -f 1 /tmp/list.txt)
do
	/usr/bin/slptool findsrvs $srvtype >> $REPDIR/$REPNAME
done

# Show the supported scopes.
addfooter
echo "Supported Scopes:" >> $REPDIR/$REPNAME
addheader
/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//' >> $REPDIR/$REPNAME

# Show the Sync Partners.
addfooter
echo "DA Sync Partners:" >> $REPDIR/$REPNAME
addheader
/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d = | sed -e 's/^[ \t]*//' >> $REPDIR/$REPNAME
addfooter

# Count the number of service registrations in memory, in DABackup, and in eDirectory.
echo "Number of Service Registrations:" >> $REPDIR/$REPNAME
addheader
echo "There are $(cat $REPDIR/$REPNAME | grep service | wc -l) service registrations in memory on $HOST." >> $REPDIR/$REPNAME
echo "There are $(ssh $SSH_HOST1:$SSH_PORT 'cat /tmp/slpServices.txt | grep service | wc -l') serivce registrations in memory on $SSH_HOST1." >> $REPDIR/$REPNAME
echo "There are $(cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l) service registrations in the DABackup file on $HOST." >> $REPDIR/$REPNAME
echo "There are $(ssh $SSH_HOST1:$SSH_PORT 'cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l') service registrations in the DABackup file on $SSH_HOST1." >> $REPDIR/$REPNAME
echo "There are $(cat /tmp/edir1.txt | grep numEntries | cut -f 2 -d : | sed -e 's/^[ \t]*//') service registrations in $TREE1 eDirectory." >> $REPDIR/$REPNAME
echo "There are $(cat /tmp/edir2.txt | grep numEntries | cut -f 2 -d : | sed -e 's/^[ \t]*//') service registrations in $TREE2 eDirectory." >> $REPDIR/$REPNAME
echo "Please check the number of service registrations in memory on the" >> $REPDIR/$REPNAME
echo "NetWare DA by issuing a display slp services at the console prompt." >> $REPDIR/$REPNAME
addfooter

# Remove the service types file
/bin/rm /tmp/list.txt
# Remove the eDirectory file
/bin/rm /tmp/edir1.txt
/bin/rm /tmp/edir2.txt
# Remove the temporary report file
/bin/rm /tmp/slpServices.txt

# E-mail the results to eDirectory reports
# mail -s "$HOST SLP Diagnostics Report" -a $REPDIR/$REPNAME $EMAIL <$INCDIR/slpDiagmsg.txt

# Finished
exit

