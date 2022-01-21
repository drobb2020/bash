#!/bin/sh

# Author: Novell Cool Solutions
# Version: 1.2
# Date Created: August 10, 2010
# Last Updated: December 30, 2010
# Purpose of script: This is a script that shows what users and how many are logged into a open enterprise server.

clear
echo "These users are logged in right now:"
# The command below uses ncpcon to list all connections to the server. We then grep CN, NOT LOGGED IN to weed out some unwanted connections.
# cut -f 2 cuts out the part we want. We then use sort to get it nice and tidy for removing duplicate entries with uniq and lastly we use 
# grep to remove entries with a * infront of them. wc -l counts lines which tells us how many users there are.
# "grep -v computerou " weeds out computers from the list so we are left with only users
ncpcon connection list | grep CN | grep -v NOT | grep -v computerou | cut -f 2 | sort | uniq -i | grep -v "[*]"
echo " "
echo " "
echo "It is $(ncpcon connection list | grep CN | grep -v NOT | grep -v computerou | cut -f 2 | sort | uniq -i | grep -v "[*]" | grep -c) users logged in at this moment."
echo " "
echo " "

exit 0
