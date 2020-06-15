#!/bin/bash
REL=0.1-3
SID=020
##############################################################################
#
#    zmdreset.sh - Reset the current zmd registration so the server can be 
#                  reregistered with Novell Customer Centre
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
# Date Created: Fri Jun 10 02:00 PM EDT 2011
# Last Updated: Wed May 27 12:29:48 2015 
# Company: Novell Canada
# Crontab command: Not recommended
# Supporting file: 
# Additional notes: 
##############################################################################

# Stop the Zenworks management daemon using
zmdstop () { 
/etc/init.d/novell-zmd stop 
}

# Remove the zmd cache using
rmcache () { 
rm -R /var/cache/zmd/* 
}

# Remove the zmd database using
rmdb () {
rm /var/lib/zmd/zmd.db 
}

# Remove the device ID using
rmdevid () {
rm /etc/zmd/deviceid 
}

# Remove the Zen secret using
rmsec () {
rm /etc/zmd/secret 
}

# Restart the Zenworks management daemon using 
zmdstrt () {
/etc/init.d/novell-zmd start 
}

# Delete the suseRegister cache file using
srcache () {
rm /var/cache/SuseRegister/lastzmdconfig.cache 
}

# Execute each function, ensuring each is complete before proceeding
zmdstop && rmcache && rmdb && rmdevid && rmsec && zmdstrt && srcache

exit 1

