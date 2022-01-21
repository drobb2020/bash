#!/bin/bash
#===============================================================================
#
#          FILE: smt-fix-repos.sh
# 
#         USAGE: ./smt-fix-repos.sh 
# 
#   DESCRIPTION: Script to fix missing or damaged rpm files for OES2-SP2 Updates
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
#                Foundation, Inc., 
#                51 Franklin Street, Fifth Floor, 
#                Boston, MA  02110-1301, USA.
#
#       OPTIONS: ---
#  REQUIREMENts: ---
#          BUGS: Report bugs to David Robb, david.robb@microfocus.com, 613-793-2281
#         NOTES: ---
#        AUTHOR: David Robb (DER), david.robb@microfocus.com
#  ORGANIZATION: Micro Focus Software (Canada) Inc
#       CREATED: Mon Feb 18 2019 12:10
#  LAST UPDATED: Wed Sep 01 2021 11:41
#       VERSION: 0.1.5
#     SCRIPT ID: 000
#===============================================================================
# Replace missing files in the full repo
cp ~/bin/oes2-errors/x86/*.rpm /srv/www/htdocs/repo/full/\$RCE/OES2-SP2-Updates/sles-10-x86_64/rpm/x86_64/
cp ~/bin/oes2-errors/i586/*.rpm /srv/www/htdocs/repo/full/\$RCE/OES2-SP2-Updates/sles-10-i586/rpm/i586/

# Replace missing files in the testing repo
cp ~/bin/oes2-errors/x86/*.rpm /srv/www/htdocs/repo/testing/\$RCE/OES2-SP2-Updates/sles-10-x86_64/rpm/x86_64/
cp ~/bin/oes2-errors/i586/*.rpm /srv/www/htdocs/repo/testing/\$RCE/OES2-SP2-Updates/sles-10-i586/rpm/i586/

# Replace missing files in the production repo
cp ~/bin/oes2-errors/x86/*.rpm /srv/www/htdocs/repo/\$RCE/OES2-SP2-Updates/sles-10-x86_64/rpm/x86_64/
cp ~/bin/oes2-errors/i586/*.rpm /srv/www/htdocs/repo/\$RCE/OES2-SP2-Updates/sles-10-i586/rpm/i586/

exit 0
