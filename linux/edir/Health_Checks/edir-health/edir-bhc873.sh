#!/bin/bash
# Author: David Robb
# Version: 1.3
# Date created: August 12, 2010
# Last updated: February 22, 2011
# Company: Novell Inc.
# Purpose of Script: Generate a daily eDir health check report for eDir 8.7.3.10
# Crontab command: 30 7 * * 1-5 /root/edir-bhc873.sh
# Supporting file: /tmp/edirhealthmessage.txt
# For reporting purposes replace the server name variable (%ServerName%) with the name of the Linux server, and enter a valid e-mail address into the mutt command (see end of script)

# Delete old Report
/bin/rm /tmp/eDir_Health_Report_%ServerName%*.txt

# Delete old ndsrepair log
/bin/rm /var/nds/ndsrepair.log

# Report Date
echo -e Report Date: > /tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
date >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
echo -e \\n >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt

echo -e eDirectory Status: >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
/usr/bin/ndsstat -s >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt

echo -e Server Uptime: >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
uptime >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
echo -e \\n >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt

echo -e Timesync Status: >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
/usr/bin/ndsrepair -T >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
echo -e \\n >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt

sleep 10

echo -e Replica Sync Status: >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
/usr/bin/ndsrepair -E >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
echo -e \\n >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt

sleep 10

echo -e External References Status: >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt
/usr/bin/ndsrepair -C -Ad -A >>/tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt

# E-mail Report
# mutt -s "%ServerName% eDir Health Report" -a /tmp/eDir_Health_Report_%ServerName%-`date +"%d-%m-%Y"`.txt edirreports@domain.name </tmp/edirhealthmessage.txt

# Finished
