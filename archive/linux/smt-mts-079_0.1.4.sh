#!/bin/bash - 
#===============================================================================
#
#          FILE: smt-mts.sh
# 
#         USAGE: ./smt-mts.sh 
# 
#   DESCRIPTION: Mirror all repositories and timestamps the new updates
#
#                Copyright (C) 2015  David Robb
#
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
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  CONTRIBUTORS: 
#  ORGANIZATION: Micro Focus
#       CREATED: Tue Aug 19 2015 11:07
#  LAST UPDATED: Wed Jan 06 2016 09:32
#      REVISION: 4
#     SCRIPT ID: 079
# SSC UNIQUE ID: ---
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
version=0.1.4                                   # version number of the script
sid=079                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # user checking routine
email=root                                      # default email value
log='/var/log/smt-mts.log'                      # logging (if required)

# Mirror all new patches down to the configured repositories
/usr/sbin/smt-mirror

# Get the Repository ID for all configured repositories
r=$(/usr/sbin/smt-repos -o -v | grep "Repository ID" | cut -f 2 -d ":" | sed -e 's/^[ \t]*//')

# now timestamp all patches so they can be installed
for i in $r
  do
    /usr/sbin/smt-staging createrepo $i -t
    /usr/sbin/smt-staging createrepo $i -p
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

exit 1

