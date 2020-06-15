#!/bin/bash - 
#===============================================================================
#
#          FILE: slpdiag.sh
# 
#         USAGE: ./slpdiag.sh 
# 
#   DESCRIPTION: A script to collect and report on openSLP registrations
#
#                Copyright (C) 2015  David Robb
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
#       OPTIONS: 59 23 * * * /root/bin/slpdiag.sh
#  REQUIREMENTS: /root/bin/slpdiagmsg.txt
#          BUGS: Report bugs to David Robb, drobb@novell.com, 613-793-2281
#         NOTES: Remember to set your custom variables
#        AUTHOR: David Robb (DER), drobb@novell.com
#  ORGANIZATION: Micro Focus
#       CREATED: Thu Mar 10 2011 08:00
#  LAST UPDATED: Mon Jul 20 2015 09:07
#      REVISION: 16
#     SCRIPT ID: 012
#===============================================================================

set -o nounset                              # Treat unset variables as an error
version=0.1.16
sid=012                                     # script ID number
ts=$(date +"%b %d %T")                      # general date/time stamp
host=$(hostname)                            # host name of local server
user=$(whoami)                              # user checking routine
email=root                                  # default email value
log='/var/log/slpdiag.log'                  # logging (if required)

# Custom variables
REPDIR=/root/reports
REPNAME=SLP_Diagnostics_Report
TMPDIR=/tmp
TMPREP=rReport.tmp
INCDIR=/root/bin
HT=${host}-${ts}
REPORT=$REPDIR/$REPNAME-$HT.txt

# LDAP
PORT=389
STYPE=sub

# eDir Tree 1 (NetWare based DA)
TREE=
HOSTIP=
USER=
PW=
BASE=

# Remote openSLP DA server
SSHHOST=
SSHPORT=22

# Functions
addspace() { echo "" >> $REPORT 
}

# Check if user is root
if [ $user != "root" ]; then
  echo "ERROR"
	echo "You must be root to run this script. Exiting..."
	echo "==============================================="
  exit 1
fi

# Create reports folder if it doesn't exist
if [ ! -e $REPDIR ]; then
  /bin/mkdir $REPDIR
fi

# Delete old report before creating new one
if [ -e $REPORT ]; then
  /bin/rm /root/reports/SLP*.txt
fi

# LDAP search of eDirectory for SLP registrations
if [ -n "$TREE" ]; then
  ldapsearch -x -h $HOSTIP -p $PORT -D $USER -w $PW -b $BASE -s $STYPE "(objectClass=sLPService)" >> /tmp/edir.tmp
fi

# Create new report
addspace
echo "--[ SLP Diagnostics Report ]------------------------------------------------" >> $REPORT
echo "--[ Report started at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]------------------------" >> $REPORT
addspace

# Generate a list of SLP registrations on the local server
/usr/bin/slptool findsrvtypes > /tmp/list.tmp

# Generate a list of SLP registration on the remote server
if [ -n "$SSHHOST" ]
    then
	/usr/bin/ssh -p $SSHPORT root@$SSHHOST '/usr/bin/slptool findsrvtypes' > /tmp/rlist.tmp
fi

# Loop through the SLP registrations file twice (once for remote server, once for local server)
if [ -e /tmp/rlist.tmp ]
    then
	for srvtype in $(cut -f 1 /tmp/rlist.tmp)
	    do
		/usr/bin/slptool findsrvs $srvtype >> $TMPDIR/$TMPREP
	    done
fi

echo "--[ SLP Configuratio File ]-------------------------------------------------" >> $REPORT
cat /etc/slp.conf | grep -v "#" | grep -v ";" | sed '/^$/d' >> $REPORT
addspace

echo "--[ SLP Service Types ]-----------------------------------------------------" >> $REPORT
addspace
for srvtype in $(cut -f 1 /tmp/list.tmp)
do
    /usr/bin/slptool findsrvs $srvtype >> $REPORT
done
addspace

# Report the configured scopes
echo "--[ Supported Scopes ]------------------------------------------------------" >> $REPORT
addspace
/usr/bin/slptool findscopes >> $REPORT
addspace

# Report the DA sync partners
echo "--[ DA Sync Partners ]------------------------------------------------------" >> $REPORT
addspace
/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d = | sed -e 's/^[ \t]*//' >> $REPORT
addspace

# Number of registrations in local memory, DABackup, and eDirectory
echo "--[ Number of Service Registrations ]---------------------------------------" >> $REPORT
addspace

echo "There are $(cat $REPORT | grep service | wc -l) service registrations in memory on $host." >> $REPORT

if [ -n "$SSHHOST" ]; then
  echo "There are $(cat /tmp/rReport.tmp | grep service | wc -l) serivce registrations in memory on $SSHHOST." >> $REPORT
fi

echo "There are $(cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l) service registrations in the DABackup file on $host." >> $REPORT

if [ -n "$SSHHOST" ]; then
  echo "There are $(ssh -p $SSHPORT root@$SSHHOST 'cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l') service registrations in the DABackup file on $SSHHOST." >> $REPORT
fi

if [ -n "$TREE" ]; then
  echo "There are $(cat /tmp/edir.tmp | grep numEntries | cut -f 2 -d : | sed -e 's/^[ \t]*//') service registrations in the $TREE eDirectory tree." >> $REPORT
  echo "Please check the number of service registrations in memory on the" >> $REPORT
  echo "NetWare DA by issuing a display slp services at the console prompt." >> $REPORT
fi

addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]-----------------------" >> $REPORT
addspace

# Remove temporary files
/bin/rm /tmp/list.tmp
if [ -n "$SSHHOST" ]; then
  /bin/rm /tmp/rlist.tmp
  /bin/rm /tmp/rReport.tmp
fi
if [ -n "$TREE" ]; then
  /bin/rm /tmp/edir.tmp
fi

# E-Mail the report to someone
if [ -n "$email" ]; then
  echo -e "Please find attached today's SLP Health Report from $host. Please store this file for historical reference." | mail -s "$host openSLP Diagnostics Report" -a $REPORT $email
fi

# Finished
exit 1

