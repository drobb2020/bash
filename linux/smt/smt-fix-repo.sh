#!/bin/bash
#===============================================================================
#
#          FILE: smt-fix-repos.sh
# 
#         USAGE: ./smt-fix-repos.sh 
# 
#   DESCRIPTION: Script to fix missing or damaged files for configured OES2-SP2 Updates
#
#                Copyright (C) 2019  David Robb
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
#                Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.)
#
#       OPTIONS: ---
#  REQUIREMENts: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: Mon Feb 18 2019 12:10
#  LAST UPDATED: Mon Feb 18 2019 12:18
#       VERSION: 1.3
#     SCRIPT ID: 000
# SSC UNIQUE ID: 00
#===============================================================================
version=0.1.3                                   # version number of the script
sid=000                                         # personal script id number
uid=00                                          # SSC/RCMP script id number
ts=$(date +"%b %d %T")                          # general date/time stamp
ds=$(date +%a)                                  # abbreviated day of the week, eg Mon
df=$(date +%A)                                  # full day of the week, eg Monday
host=$(hostname)                                # host name of local server
user=$(whoami)                                  # who is running the script
rbin='/root/bin'                                # root's bin folder
email=root                                      # who to send email to (comma separated list)
log='/var/log/smt/smt-fix.log'                  # logging (if required)

# Replace missing files in the full repo
cp ~/bin/missing/*.rpm /srv/www/htdocs/repo/full/\$RCE/OES2-SP2-Updates/sles-10-x86_64/rpm/x86_64/

# Replace missing files in the testing repo
cp ~/bin/missing/*.rpm /srv/www/htdocs/repo/testing/\$RCE/OES2-SP2-Updates/sles-10-x86_64/rpm/x86_64/

# Replace missing files in the production repo
cp ~/bin/missing/*.rpm /srv/www/htdocs/repo/\$RCE/OES2-SP2-Updates/sles-10-x86_64/rpm/x86_64/

exit 1
