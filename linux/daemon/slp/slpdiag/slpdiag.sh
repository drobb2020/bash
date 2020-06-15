#!/bin/bash - 
#===============================================================================
#
#          FILE: slpdiag.sh
# 
#         USAGE: ./slpdiag.sh 
#
#   DESCRIPTION: A script to collect and report on openSLP registrations
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
#       OPTIONS: 59 23 * * * /root/bin/slpdiag.sh
#  REQUIREMENTS: 
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus Software (Canada) Inc.
#       CREATED: Thu Mar 10 2011 08:00
#  LAST UPDATED: Mon Mar 12 2018 12;13
#       VERSION: 19
#     SCRIPT ID: 012
# SSC UNIQUE ID: 00
#===============================================================================
version=0.1.19                                  # version number of the script
sid=012                                         # personal script id number
uid=00                                          # SSC|RCMP script id number
#===============================================================================
ts=$(date +"%b %d %T")                          # general date|time stamp
ds=$(date +%a)                                  # short day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
email=                                          # email recipient(s)
log='/var/log/slpdiag.log'                      # logging (if required)
repdir=/root/reports				# folder where the final report is written
repname=slp_diagnostics-${host}                 # report name
tmpdir=/tmp                                     # temporary folder
tmprep=rreport.tmp                              # temporary report
incdir=/root/bin                                # folder to include
ht=${host}-${ts}                                # hostname and timestamp to add to report name
report=$repdir/$repname.txt                     # report name
#===============================================================================

# LDAP
port=389
stype=sub

# eDir Tree 1 (NetWare based DA)
tree=
hostip=
user=
pswd=
base=

# Remote openSLP DA server
sshhost=
sshport=22

# Functions
addspace() { echo "" >> $report 
}

# Check if user is root
#if [ $user != "root" ]; then
#  echo "ERROR"
#	echo "You must be root to run this script. Exiting..."
#	echo "==============================================="
#  exit 1
#fi

# Create reports folder if it doesn't exist
if [ ! -e $repdir ]; then
  /bin/mkdir $repdir
fi

# Delete old report before creating new one
if [ -e $report ]; then
  /bin/rm /root/reports/slp*.txt
fi

# LDAP search of eDirectory for SLP registrations
if [ -n "$tree" ]; then
  ldapsearch -x -h $hostip -p $port -D $user -w $pswd -b $base -s $stype "(objectClass=sLPService)" >> /tmp/edir.tmp
fi

# Create new report
touch $report
addspace
echo "--[ SLP Diagnostics Report ]------------------------------------------------" >> $report
echo "--[ Report started at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]------------------------" >> $report
addspace

# Generate a list of SLP registrations on the local server
/usr/bin/slptool findsrvtypes > /tmp/list.tmp

# Generate a list of SLP registration on the remote server
#if [ -n "$sshhost" ]
#    then
#	/usr/bin/ssh -p $sshport root@$sshhost '/usr/bin/slptool findsrvtypes' > /tmp/rlist.tmp
# fi

# Loop through the SLP registrations file twice (once for remote server, once for local server)
#if [ -e /tmp/rlist.tmp ]
#    then
#	for srvtype in $(cut -f 1 /tmp/rlist.tmp)
#	    do
#		/usr/bin/slptool findsrvs $srvtype >> $tmpdir/$tmprep
#	    done
#fi

echo "--[ SLP Configuratio File ]-------------------------------------------------" >> $report
cat /etc/slp.conf | grep -v "#" | grep -v ";" | sed '/^$/d' >> $report
addspace

echo "--[ SLP Service Types ]-----------------------------------------------------" >> $report
addspace
for srvtype in $(cut -f 1 /tmp/list.tmp)
do
    /usr/bin/slptool findsrvs $srvtype >> $report
done
addspace

# Report the configured scopes
echo "--[ Supported Scopes ]------------------------------------------------------" >> $report
addspace
/usr/bin/slptool findscopes >> $report
addspace

# Report the DA sync partners
echo "--[ DA Sync Partners ]------------------------------------------------------" >> $report
addspace
/usr/bin/slptool getproperty net.slp.DAAddresses | cut -f 2 -d = | sed -e 's/^[ \t]*//' >> $report
addspace

# Number of registrations in local memory, DABackup, and eDirectory
echo "--[ Number of Service Registrations ]---------------------------------------" >> $report
addspace

echo "There are $(cat $report | grep service | wc -l) service registrations in memory on $host." >> $report

if [ -n "$sshhost" ]; then
  echo "There are $(cat /tmp/rReport.tmp | grep service | wc -l) serivce registrations in memory on $sshhost." >> $report
fi

echo "There are $(cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l) service registrations in the DABackup file on $host." >> $report

if [ -n "$sshhost" ]; then
  echo "There are $(ssh -p $sshport root@$sshhost 'cat /etc/slp.reg.d/slpd/DABackup | grep service | wc -l') service registrations in the DABackup file on $sshhost." >> $report
fi

if [ -n "$tree" ]; then
  echo "There are $(cat /tmp/edir.tmp | grep numEntries | cut -f 2 -d : | sed -e 's/^[ \t]*//') service registrations in the $tree eDirectory tree." >> $report
  echo "Please check the number of service registrations in memory on the" >> $report
  echo "NetWare DA by issuing a display slp services at the console prompt." >> $report
fi

addspace
echo "--[ Report finished at: $(date +"%a, %b, %d, %Y %k:%M:%S") ]-----------------------" >> $report
addspace

# Remove temporary files
/bin/rm /tmp/list.tmp
if [ -n "$sshhost" ]; then
  /bin/rm /tmp/rlist.tmp
  /bin/rm /tmp/rreport.tmp
fi
if [ -n "$tree" ]; then
  /bin/rm /tmp/edir.tmp
fi

# E-Mail the report to someone
if [ -n "$email" ]; then
  echo -e "Please find attached today's SLP Health Report from $host. Please store this file for historical reference." | mail -s "$host openSLP Diagnostics Report" -a $report $email
fi

# Finished
exit 1

