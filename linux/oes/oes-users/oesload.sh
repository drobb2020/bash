#!/bin/sh

# Author: Novell Cool Solutions
# Version: 1.2
# Date Created: August 10, 2010
# Last Updated: December 30, 2010
# Purpose of script: To check the logon load on an OES Server

inloggade=$(ncpcon connection list | grep CN | grep -v NOT | grep -v cumputerou | cut -f 2 | sort | uniq -i | grep -v "[*]" | grep -c)
#  In grep -v cumputerou replace computerou with the name of the container where you store your computers
load=$(top -b -n 1 | grep Cpu | cut -f 3 -d " " | cut -f 1 -d "%")
date=$(date  +%Y-%m-%d*%k:%M)
echo "$date", "$inloggade", "$load" >> /var/log/oesusers.log

