#!/bin/bash - 
#===============================================================================
#
#          FILE: smt-mts.sh
# 
#         USAGE: ./smt-mts.sh 
# 
#   DESCRIPTION: Mirror all repositories and timestamps the new updates
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
#       CREATED: Tue Aug 19 2015 11:07
#   LAST UDATED: Wed Oct 24 2018 10:30
#       VERSION: 0.1.6
#     SCRIPT ID: 079
# SSC SCRIPT ID: 00
#===============================================================================
version=0.1.6                                    # version number of the script
sid=079                                          # personal script ID
uid=00                                           # SSC | RCMP script ID
#===============================================================================
ts=$(date +"%b %d %T")                           # general date|time stamp
ds=$(date +%a)                                   # short day of the week eg. Mon
df=$(date +%A)                                   # long day of the week eg. Monday
host=$(hostname)                                 # hostname of the local server
fqdn=$(hostname -f)                              # fully qualified host name of local server
lip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127) # local IP Addr
user=$(whoami)                                   # who is running the script
mfrom=smt-sync                                   # email sender
email=root                                       # email recipient(s)
log='/var/log/smt-mts.log'                       # log name and location (if required)
#===============================================================================

# Mirror all new patches down to the configured repositories
/usr/sbin/smt-mirror

# Get the Repository ID for all configured repositories
r=$(/usr/sbin/smt-repos -o -v | grep "[*]" | awk '{ print $5 }')

# now timestamp all patches so they can be installed
for i in $r
  do
    echo "Timestamping testing repositories"
    /usr/sbin/smt-staging -L $log createrepo $i --testing
	echo "Testing repositories complete"
	clear
	echo ""
    /usr/sbin/smt-staging -L $log createrepo $i --production
  done

# Completion message
echo ""
echo "---------------------------------------------------------------------"
echo "SMT repositories updated and ready for patching"
echo "---------------------------------------------------------------------"
echo "All configured repositories have been mirrored down from NCC/SCC, and"
echo "timestamped. Servers can now be patched to the latest releases."
echo "Have fun patching."
echo "---------------------------------------------------------------------"

# Finished
exit 1

