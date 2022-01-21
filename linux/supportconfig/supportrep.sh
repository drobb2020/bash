#!/bin/bash

# Author: David Robb
# Version: 1.2
# Date created: August 17, 2009
# Last updated: February 22, 2011
# Company: Novell Inc.
# Purpose of Script: Generate a Monthly support config report by using this script and cron
# Crontab command: 0 5 15 * * /root/supportrep.sh
# Supporting file: /tmp/supportmessage.txt

# For reporting purposes replace the server name variable (%ServerName%) with the name of the Linux server, and enter a valid e-mail address into the mutt command (see end of script)

# Delete old Support Config Reports
/bin/rm /var/log/nts_%ServerName%_*.tbz
/bin/rm /var/log/nts_%ServerName%_*.tbz.md5

# Support Config Report Generator script
/sbin/supportconfig

# E-mail Report
# mutt -s "%ServerName% Support Config Report" -a /var/log/nts_%ServerName%_*.tbz edirreports@bruyere.org </tmp/supportmessage.txt

# Finished
exit 0

