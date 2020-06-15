#!/bin/bash
REL=0.01-2
##############################################################################
#
#    restartedir.sh - Restart eDir without notifying users
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
# Date Created: Tue Mar 22 11:53:52 EDT 2011
# Last updated: Thu Mar 29 15:38:08 2012 
# Crontab command: not recommended
# Supporting file: none
# Additional notes: 
##############################################################################
# Declare variables
maxcon=`ncpcon connections 2>/dev/null | sed -ne  "s/.*Connection Slots Allocated\t//pg"`

clear

# Run the script
count=0
if [ "$1" == "disable" ]
   then
   disable=`ncpcon disable login 2>/dev/null`
   if echo $disable | grep "Login is now disabled" 1>/dev/null 2>&1
      then
         echo $disable
         echo -e "Don't forget to 'ncpcon enable login' if you don't restart the server"
      else
         echo -e "'ncpcon disable login' is not supported... Hurry up to bounce the server..."
   fi
fi
echo Max Connections = $maxcon

while [ $count -le $maxcon ]
do
   ncpcon connection clear $count 1>/dev/null 2>&1
   count=`expr $count + 1`
done
echo "All connections are cleared."
rcndsd restart
echo "eDirectory has been restarted!"

exit

