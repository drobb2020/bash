#!/bin/bash
REL=0.1.1
##############################################################################
#
#    trustee_backup.sh - Backup all NSS Trustee data for all volumes.
#                        This is not the same as using metamig!
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
# Date Created: Tue Oct 02 14:38:17 2012
# Last updated: Wed Oct 03 11:12:20 2012
# Suggested Crontab command: 00 5 * * * /root/bin/trustee_backup.sh
# Supporting file: 
# Additional notes: 
##############################################################################
# Declare varilables
DOWS=$(date +%a)
DOWF=$(date +%A)

rm /backup/trustee/$DOWS.txt
/bin/zTrustee /R ALL RESTORE ALL /backup/trustee/$1.txt

exit

