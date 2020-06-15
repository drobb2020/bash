#!/bin/bash
REL=0.01-11
##############################################################################
#
#    slpdiag.sh - To generate a report on the slp registrations on a 
#                 server. Similar to display slp services on NetWare
#    Copyright (C) 2012  David Robb
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
# Date created: March 10, 2011
# Last updated: Thu May 17 14:57:55 2012 
# Company: Novell Inc.
# Crontab command: Not recommended
# Supporting file: /root/bin/slpdiagmsg.txt
# Remember to set the custom variables for your environment
##############################################################################
# Declare variables
HOST=$(hostname)
TODAY=$(date +"%d-%m-%Y")
WHO=$(whoami)

# Custom variables
REPDIR=/root/reports
REPNAME=SLP_Diagnostics_Report
TMPDIR=/tmp
TMPREP=slpServices.txt
INCDIR=/root/bin
EMAIL=edirreports@excs2net.org
HT=$HOST-$TODAY
REPORT=$REPDIR/$REPNAME-from-$HT.txt
# NDSCFG=/etc/opt/novell/eDirectory/conf/nds.conf
# NDSBIN=/opt/novell/eDirectory/bin

# LDAP Variables
# Common
# PORT=389
# STYPE=sub

# Tree1
# TREE1=EXCS2-TREE
# HOSTIP1=192.168.0.51
# NAME1="cn=admin,o=excs2"
# PW1=nashira!=000
# BASE1=o=excs2

# Tree2
# TREE2=
# HOSTIP2=
# NAME2=
# PW2=
# BASE2=

# SSH Variables
# Common
# SSH_PORT=22
# openSLP Server1
# SSH_HOST1=excs2-ott-s001.excs2net.org
# openSLP Server2
# SSH_HOST2=

# Functions
addspace() { echo "" >> $REPORT
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
if [ -e $REPDIR/SLP_Diagnostics_Report*.txt ]
		then
		/bin/rm $REPDIR/SLP_Diagnostics_Report*.txt
		else
				echo "Old report does not exist, continuing..."
fi

# Run an ldapsearch to get SLP records from eDirectory if you have NovellSLP DA's
# ldapsearch -x -h $HOSTIP1 -p $PORT -D $NAME1 -w $PW1 -b $BASE1 -s $STYPE "(objectClass=sLPService)" >> /tmp/edir1.txt
# ldapsearch -x -h $HOSTIP2 -p $PORT -D $NAME2 -w $PW2 -b $BASE2 -s $STYPE "(objectClass-sLPService)" >> /tmp/edir2.txt

# Create a new report and set the date-timestamp at the top
addspace
echo "--[ SLP Diagnostics Report v${REL} ]---------------------------------------" >> $REPORT
echo "--[ Report started at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]------------------------" >> $REPORT
addspace

# Generate a list of slp services
/usr/bin/slptool findsrvtypes > /tmp/list.txt

# Loop through and run slptool for each service type and write each iteration to a temporary report
for srvtype in $(cut -f 1 /tmp/list.txt)
do
	/usr/bin/slptool findsrvs $srvtype >> $TMPDIR/$TMPREP
done

# Loop through and run slptool for each service type and write each iteration to the final report
echo "--[ SLP Service Types ]-----------------------------------------------------" >> $REPORT
for srvtype in $(cut -f 1 /tmp/list.txt)
do
	/usr/bin/slptool findsrvs $srvtype >> $REPORT
done
addspace

# Show the supported scopes.
echo "--[ Supported Scopes ]------------------------------------------------------" >> $REPORT
/usr/bin/slptool findscopes | sed -e 's/^[ \t]*//' >> $REPORT
addspace

# Show the Sync Partners
echo "--[ DA Sync Partners ]------------------------------------------------------" >> $REPORT
/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d = | sed -e 's/^[ \t]*//' >> $REPORT
addspace

# Count the number of service registrations in memory, in DABackup, and in eDirectory.
echo "--[ Number of Service Registrations ]---------------------------------------" >> $REPORT
echo "There are $(cat $REPORT | grep service | wc -l) service registrations in memory on $HOST." >> $REPORT
# echo "There are $(ssh $SSH_HOST1:$SSH_PORT 'cat /tmp/slpServices.txt | grep service | wc -l') serivce registrations in memory on $SSH_HOST1." >> $REPORT
echo "There are $(cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l) service registrations in the DABackup file on $HOST." >> $REPORT
# echo "There are $(ssh $SSH_HOST1:$SSH_PORT 'cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l') service registrations in the DABackup file on $SSH_HOST1." >> $REPORT
# echo "There are $(cat /tmp/edir1.txt | grep numEntries | cut -f 2 -d : | sed -e 's/^[ \t]*//') service registrations in $TREE1 eDirectory." >> $REPORT
# echo "There are $(cat /tmp/edir2.txt | grep numEntries | cut -f 2 -d : | sed -e 's/^[ \t]*//') service registrations in $TREE2 eDirectory." >> $REPORT
# echo "Please check the number of service registrations in memory on the" >> $REPORT
# echo "NetWare DA by issuing a display slp services at the console prompt." >> $REPORT
addspace

# Remove the service types file
/bin/rm /tmp/list.txt
# Remove the eDirectory file
# /bin/rm /tmp/edir1.txt
# /bin/rm /tmp/edir2.txt
# Remove the temporary report file
/bin/rm /tmp/slpServices.txt

# E-mail the results to eDirectory reports
mail -s "$HOST SLP Diagnostics Report" -a $REPORT $EMAIL <$INCDIR/slpdiagmsg.txt

# Finished
exit

