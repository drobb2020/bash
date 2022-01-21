#!/bin/bash

# Created by John Vindiola - Identity Automation - john.vindiola@idauto.net
# Simple script to output all SLP services found by the server
# Similar to netware command "display slp services"
# Last updated: December 30, 2010
# Replace the server name variable (%ServerName%) with the name of the Linux server

#delete the text files from the last time this was run
rm /tmp/allslp*.txt > /dev/null 2>&1
rm /tmp/slpsrvtypes_%ServerName%-`date +"%d-%m-%Y"`.txt > /dev/null 2>&1


#find the different service types registered in SLP and write to a text file
/usr/bin/slptool findsrvtypes > /tmp/slpsrvtypes_%ServerName%-`date +"%d-%m-%Y"`.txt


#Loop through and run slptool for each service type
#writing each iteration to a file
for srvtype in $(cut -f 1 /tmp/slpsrvtypes_%ServerName%-`date +"%d-%m-%Y"`.txt)
do
	/usr/bin/slptool findsrvs $srvtype >> /tmp/allslpservs_%ServerName%-`date +"%d-%m-%Y"`.txt 
done

#remove the service types file
rm /tmp/slpsrvtypes_%ServerName%-`date +"%d-%m-%Y"`.txt > /dev/null 2>&1

#output the results to the screen using less
less /tmp/allslpservs_%ServerName%-`date +"%d-%m-%Y"`.txt

echo "The results are stored in /tmp/allslpservs_%ServerName%-`date +"%d-%m-%Y"`.txt for further review."

# E-mail the results to eDirectory Reports
mutt -s "%ServerName% SLP Services Report" -a /tmp/allslpservs_%ServerName%-`date +"%d-%m-%Y"`.txt edirreports@bruyere.org </tmp/edirhealthmessage.txt
#
# Finished
